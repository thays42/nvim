-- Pure-Lua cobertura XML parser for nvim-coverage
-- Parses covr's cobertura output without requiring lua-xmlreader
local M = {}

--- Parse cobertura XML content into nvim-coverage format
-- @param content string The XML file content
-- @param path_mappings table Optional path prefix mappings
-- @return table { files = { [filename] = { executed_lines = {}, missing_lines = {} } } }
function M.parse(content, path_mappings)
  path_mappings = path_mappings or {}

  local result = {
    files = {},
  }

  -- Extract source directory from <source> element (covr includes this)
  local source_dir = content:match('<source>([^<]+)</source>') or ''
  if source_dir ~= '' and not source_dir:match('/$') then
    source_dir = source_dir .. '/'
  end

  -- Find all <class> elements and extract filename + line coverage
  for fname, block in content:gmatch('<class[^>]*filename="([^"]+)"[^>]*>(.-)</class>') do
    -- Prepend source directory to get absolute path
    local full_path = source_dir .. fname

    -- Apply path mappings
    local mapped_path = full_path
    for prefix, replacement in pairs(path_mappings) do
      if full_path:sub(1, #prefix) == prefix then
        mapped_path = replacement .. full_path:sub(#prefix + 1)
        break
      end
    end

    -- Initialize file entry
    if not result.files[mapped_path] then
      result.files[mapped_path] = {
        executed_lines = {},
        missing_lines = {},
      }
    end

    local file_data = result.files[mapped_path]

    -- Parse <line number="N" hits="H"/> elements
    for line_num, hits in block:gmatch('<line[^>]*number="(%d+)"[^>]*hits="(%d+)"[^>]*/?>') do
      local ln = tonumber(line_num)
      local hit_count = tonumber(hits)

      if hit_count > 0 then
        -- Line was executed
        if not vim.tbl_contains(file_data.executed_lines, ln) then
          table.insert(file_data.executed_lines, ln)
        end
      else
        -- Line was not executed
        if not vim.tbl_contains(file_data.missing_lines, ln) then
          table.insert(file_data.missing_lines, ln)
        end
      end
    end
  end

  -- Sort line numbers for consistent display
  for _, file_data in pairs(result.files) do
    table.sort(file_data.executed_lines)
    table.sort(file_data.missing_lines)
  end

  return result
end

--- Load and parse a cobertura XML file
-- @param filepath string|Path Path to the coverage.xml file
-- @param path_mappings table Optional path prefix mappings
-- @return table Parsed coverage data
function M.load_file(filepath, path_mappings)
  local path = type(filepath) == 'string' and filepath or filepath:absolute()

  local f = io.open(path, 'r')
  if not f then
    return { files = {} }
  end

  local content = f:read '*a'
  f:close()

  return M.parse(content, path_mappings)
end

return M
