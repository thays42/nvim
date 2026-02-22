-- Navigation utilities for R coverage
local M = {}

local cobertura = require 'coverage-r.cobertura'

-- Cache for coverage data
local coverage_cache = nil
local coverage_file_mtime = nil

--- Get coverage data, using cache if file hasn't changed
local function get_coverage_data()
  local cwd = vim.fn.getcwd()
  local coverage_file = cwd .. '/coverage.xml'

  -- Check if file exists
  local stat = vim.uv.fs_stat(coverage_file)
  if not stat then
    return nil
  end

  -- Use cache if file hasn't changed
  if coverage_cache and coverage_file_mtime == stat.mtime.sec then
    return coverage_cache
  end

  -- Parse and cache
  coverage_cache = cobertura.load_file(coverage_file, {})
  coverage_file_mtime = stat.mtime.sec
  return coverage_cache
end

--- Get uncovered lines for the current buffer
local function get_uncovered_lines()
  local data = get_coverage_data()
  if not data then
    return nil
  end

  local filepath = vim.fn.expand '%:p'
  local file_coverage = data.files[filepath]
  if not file_coverage then
    return nil
  end

  return file_coverage.missing_lines
end

--- Jump to next uncovered line
function M.next_uncovered()
  local lines = get_uncovered_lines()
  if not lines or #lines == 0 then
    vim.notify('No uncovered lines in this file', vim.log.levels.INFO)
    return
  end

  local cursor_line = vim.fn.line '.'

  -- Find next uncovered line after cursor
  for _, line in ipairs(lines) do
    if line > cursor_line then
      vim.api.nvim_win_set_cursor(0, { line, 0 })
      vim.cmd 'normal! zz'
      return
    end
  end

  -- Wrap to first uncovered line
  vim.api.nvim_win_set_cursor(0, { lines[1], 0 })
  vim.cmd 'normal! zz'
  vim.notify('Wrapped to first uncovered line', vim.log.levels.INFO)
end

--- Jump to previous uncovered line
function M.prev_uncovered()
  local lines = get_uncovered_lines()
  if not lines or #lines == 0 then
    vim.notify('No uncovered lines in this file', vim.log.levels.INFO)
    return
  end

  local cursor_line = vim.fn.line '.'

  -- Find previous uncovered line before cursor
  for i = #lines, 1, -1 do
    if lines[i] < cursor_line then
      vim.api.nvim_win_set_cursor(0, { lines[i], 0 })
      vim.cmd 'normal! zz'
      return
    end
  end

  -- Wrap to last uncovered line
  vim.api.nvim_win_set_cursor(0, { lines[#lines], 0 })
  vim.cmd 'normal! zz'
  vim.notify('Wrapped to last uncovered line', vim.log.levels.INFO)
end

--- Clear the coverage cache (useful after regenerating coverage)
function M.clear_cache()
  coverage_cache = nil
  coverage_file_mtime = nil
end

return M
