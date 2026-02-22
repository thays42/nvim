-- Telescope picker for R function coverage
local M = {}

local cobertura = require 'coverage-r.cobertura'

--- Get function definitions from an R file using treesitter
-- @param filepath string
-- @return table[] List of { name, start_line, end_line }
local function get_r_functions(filepath)
  local functions = {}

  -- Read file content
  local f = io.open(filepath, 'r')
  if not f then
    return functions
  end
  local content = f:read '*a'
  f:close()

  -- Parse with treesitter
  local ok, parser = pcall(vim.treesitter.get_string_parser, content, 'r')
  if not ok then
    return functions
  end

  local tree = parser:parse()[1]
  if not tree then
    return functions
  end

  local root = tree:root()

  -- Query for function assignments: name <- function(...) or name = function(...)
  local query_str = [[
    (binary_operator
      lhs: (identifier) @name
      operator: ["<-" "="]
      rhs: (function_definition)) @func
  ]]

  local query = vim.treesitter.query.parse('r', query_str)

  for id, node, _ in query:iter_captures(root, content, 0, -1) do
    local capture_name = query.captures[id]
    if capture_name == 'func' then
      local start_row, _, end_row, _ = node:range()
      -- Get the function name from the lhs
      local name_node = node:named_child(0)
      if name_node then
        local name = vim.treesitter.get_node_text(name_node, content)
        table.insert(functions, {
          name = name,
          start_line = start_row + 1, -- 1-indexed
          end_line = end_row + 1,
        })
      end
    end
  end

  return functions
end

--- Calculate coverage stats for a function
-- @param func table { name, start_line, end_line }
-- @param file_coverage table { executed_lines, missing_lines }
-- @param total_lines number Total lines in file
-- @return table { green, red, gray }
local function calc_function_coverage(func, file_coverage)
  local green = 0 -- covered
  local red = 0 -- uncovered
  local gray = 0 -- not tracked (comments, whitespace, etc.)

  local executed = {}
  local missing = {}

  for _, ln in ipairs(file_coverage.executed_lines or {}) do
    executed[ln] = true
  end
  for _, ln in ipairs(file_coverage.missing_lines or {}) do
    missing[ln] = true
  end

  for line = func.start_line, func.end_line do
    if executed[line] then
      green = green + 1
    elseif missing[line] then
      red = red + 1
    else
      gray = gray + 1
    end
  end

  return { green = green, red = red, gray = gray }
end

--- Build list of functions with coverage stats
-- @return table[] List of { name, file, line, green, red, gray }
function M.get_function_coverage()
  local cwd = vim.fn.getcwd()
  local coverage_file = cwd .. '/coverage.xml'

  -- Load coverage data
  local data = cobertura.load_file(coverage_file, {})
  if not data or not data.files or vim.tbl_isempty(data.files) then
    return nil, 'No coverage data found'
  end

  local results = {}

  -- Process each file with coverage
  for filepath, file_coverage in pairs(data.files) do
    -- Only process R files in R/ directory
    if filepath:match('/R/[^/]+%.[rR]$') then
      local functions = get_r_functions(filepath)

      for _, func in ipairs(functions) do
        local stats = calc_function_coverage(func, file_coverage)
        table.insert(results, {
          name = func.name,
          file = filepath,
          filename = filepath:match('([^/]+)$'),
          line = func.start_line,
          green = stats.green,
          red = stats.red,
          gray = stats.gray,
        })
      end
    end
  end

  -- Filter out fully covered functions (no uncovered lines)
  local filtered = vim.tbl_filter(function(item)
    return item.red > 0
  end, results)

  -- Sort by red (uncovered) descending - show least covered first
  table.sort(filtered, function(a, b)
    if a.red ~= b.red then
      return a.red > b.red
    end
    return a.name < b.name
  end)

  return filtered
end

--- Open telescope picker for function coverage
function M.pick()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope not available', vim.log.levels.ERROR)
    return
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local entry_display = require 'telescope.pickers.entry_display'

  local results, err = M.get_function_coverage()
  if not results then
    vim.notify(err or 'Failed to get coverage data', vim.log.levels.ERROR)
    return
  end

  if #results == 0 then
    vim.notify('No functions found in coverage data', vim.log.levels.INFO)
    return
  end

  -- Calculate max widths for alignment
  local max_name = 0
  local max_file = 0
  for _, item in ipairs(results) do
    max_name = math.max(max_name, #item.name)
    max_file = math.max(max_file, #item.filename)
  end

  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = max_name + 1 },
      { width = max_file + 1 },
      { width = 5 },
      { width = 5 },
      { width = 5 },
    },
  }

  local function make_display(entry)
    return displayer {
      { entry.value.name, 'TelescopeResultsIdentifier' },
      { entry.value.filename, 'TelescopeResultsComment' },
      { tostring(entry.value.green), 'DiagnosticOk' },
      { tostring(entry.value.red), 'DiagnosticError' },
      { tostring(entry.value.gray), 'Comment' },
    }
  end

  pickers
    .new({}, {
      prompt_title = 'Function Coverage (G/R/C)',
      finder = finders.new_table {
        results = results,
        entry_maker = function(item)
          return {
            value = item,
            display = make_display,
            ordinal = item.name .. ' ' .. item.filename,
            filename = item.file,
            lnum = item.line,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = conf.grep_previewer {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            vim.cmd('edit ' .. selection.filename)
            vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
            vim.cmd 'normal! zz'
          end
        end)
        return true
      end,
    })
    :find()
end

return M
