-- R language support for nvim-coverage
-- Uses covr's cobertura XML output with pure-Lua parser (no luarocks dependency)
local M = {}

local Path = require 'plenary.path'
local common = require 'coverage.languages.common'
local config = require 'coverage.config'
local util = require 'coverage.util'
local cobertura = require 'coverage-r.cobertura'

--- Returns a list of signs to be placed.
M.sign_list = common.sign_list

--- Returns a summary report.
M.summary = common.summary

--- Loads a coverage report from cobertura XML.
-- @param callback called with the results of the coverage report
M.load = function(callback)
  local r_config = config.opts.lang.r
  local p = Path:new(util.get_coverage_file(r_config.coverage_file))
  if not p:exists() then
    vim.notify('No coverage file exists. Run: covr::to_cobertura(covr::package_coverage(), "coverage.xml")', vim.log.levels.INFO)
    return
  end

  local result = cobertura.load_file(p:absolute(), r_config.path_mappings or {})
  callback(result)
end

return M
