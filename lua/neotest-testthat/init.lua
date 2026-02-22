-- Local neotest adapter for R testthat
-- Based on neotest adapter interface

---@class neotest.Adapter
local M = { name = 'neotest-testthat' }

---Find the project root by looking for DESCRIPTION file (R package marker)
---@param dir string
---@return string|nil
function M.root(dir)
  local lib = require 'neotest.lib'
  return lib.files.match_root_pattern('DESCRIPTION')(dir)
end

---Filter directories during scanning
---@param name string
---@return boolean
function M.filter_dir(name)
  -- Skip common non-test directories
  local dominated = { '.git', 'node_modules', 'renv', '.Rproj.user', 'man', 'vignettes' }
  for _, d in ipairs(dominated) do
    if name == d then
      return false
    end
  end
  return true
end

---Check if a file is a test file
---@param file_path string
---@return boolean
function M.is_test_file(file_path)
  if not file_path then
    return false
  end
  -- Must be in tests/testthat/ and start with test
  return file_path:match('tests/testthat/test[^/]*%.[rR]$') ~= nil
end

-- Treesitter query for finding testthat tests
local query = [[
  ;; test_that("description", { ... })
  (call
    function: (identifier) @func.name (#eq? @func.name "test_that")
    arguments: (arguments
      (argument
        value: (string) @test.name)))
  @test.definition

  ;; testthat::test_that("description", { ... })
  (call
    function: (namespace_operator
      lhs: (identifier) @pkg (#eq? @pkg "testthat")
      rhs: (identifier) @func.name (#eq? @func.name "test_that"))
    arguments: (arguments
      (argument
        value: (string) @test.name)))
  @test.definition

  ;; it("description", { ... }) - BDD style
  (call
    function: (identifier) @func.name (#eq? @func.name "it")
    arguments: (arguments
      (argument
        value: (string) @test.name)))
  @test.definition

  ;; describe("description", { ... }) - BDD style namespace
  (call
    function: (identifier) @func.name (#eq? @func.name "describe")
    arguments: (arguments
      (argument
        value: (string) @namespace.name)))
  @namespace.definition
]]

---Parse test positions from file
---@param file_path string
---@return neotest.Tree|nil
function M.discover_positions(file_path)
  local lib = require 'neotest.lib'
  return lib.treesitter.parse_positions(file_path, query, {
    nested_tests = true,
    require_namespaces = false,
    position_id = function(position, namespaces)
      -- Build unique ID from file + namespaces + test name
      local parts = { position.path }
      for _, ns in ipairs(namespaces) do
        table.insert(parts, ns.name)
      end
      table.insert(parts, position.name)
      return table.concat(parts, '::')
    end,
  })
end

---Build the test execution spec
---@param args neotest.RunArgs
---@return neotest.RunSpec|nil
function M.build_spec(args)
  local position = args.tree:data()
  local root = M.root(position.path)

  if not root then
    return nil
  end

  local r_code

  if position.type == 'test' then
    -- Run specific test using testthat::test_file with desc filter
    local test_name = position.name:gsub('^["\']', ''):gsub('["\']$', '')
    -- Escape for R regex
    test_name = test_name:gsub('([\\%(%)%.%+%*%?%[%]%^%$])', '\\%1')
    r_code = string.format(
      [[pkgload::load_all('%s', quiet = TRUE); testthat::test_file('%s', desc = '%s')]],
      root,
      position.path,
      test_name
    )
  elseif position.type == 'file' then
    -- Run all tests in a specific file
    r_code = string.format(
      [[pkgload::load_all('%s', quiet = TRUE); testthat::test_file('%s')]],
      root,
      position.path
    )
  else
    -- Run all tests in project
    r_code = string.format([[devtools::test('%s')]], root)
  end

  return {
    command = { 'Rscript', '-e', r_code },
    cwd = root,
    env = {
      RENV_CONFIG_SYNCHRONIZED_CHECK = 'FALSE',
    },
    context = {
      file = position.path,
      position = position,
    },
  }
end

---Parse test results
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function M.results(spec, result, tree)
  local results = {}
  local output = result.output

  -- Read output file
  local content = ''
  if output then
    local f = io.open(output, 'r')
    if f then
      content = f:read '*a'
      f:close()
    end
  end

  -- Detect failure from testthat output patterns
  -- testthat shows "[ FAIL n ]" where n > 0 for failures
  -- Also check for R errors in test execution (not warnings)
  local has_failure = false

  -- Check for testthat failure count > 0
  local fail_count = content:match('%[ FAIL (%d+) %]')
  if fail_count and tonumber(fail_count) > 0 then
    has_failure = true
  end

  -- Check for R execution errors (but not the word "Error" in general text)
  if content:match('Error in') or content:match('Execution halted') then
    has_failure = true
  end

  -- For simplicity, mark all tests based on overall result
  for _, pos in tree:iter() do
    if pos.type == 'test' then
      results[pos.id] = {
        status = has_failure and 'failed' or 'passed',
        output = output,
      }
    end
  end

  return results
end

return M
