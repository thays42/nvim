-- Lua buffer-local "run" keymaps: execute the current file in luajit, or run
-- busted in its directory -- without leaving nvim. These are zero-dependency
-- fallbacks; rich spec running lives in neotest (<leader>t*).
--
-- Namespace note: <leader>r is the global [R]eview group, so these hang off
-- <leader>R ([R]un). Rebind freely -- it's just the strings below.

-- Open a bottom split running `cmd` (a list -- no shell quoting headaches),
-- optionally with a working directory, and drop into terminal-insert.
local function run_in_split(cmd, cwd)
  vim.cmd 'botright 15split | enew'
  vim.fn.jobstart(cmd, { term = true, cwd = cwd })
  vim.cmd 'startinsert'
end

-- <leader>Rl : run THIS file through luajit (love2d's runtime). cwd = file's
-- dir so relative requires in scratch scripts resolve.
vim.keymap.set('n', '<leader>Rl', function()
  local file = vim.fn.expand '%:p'
  run_in_split({ 'luajit', file }, vim.fn.expand '%:p:h')
end, { buffer = true, desc = '[R]un: this file in [L]uajit' })

-- <leader>Rb : run busted from THIS file's directory. cwd = file's dir so the
-- local .busted config (lua=luajit, ROOT) and require("solution") both resolve.
vim.keymap.set('n', '<leader>Rb', function()
  run_in_split({ 'busted' }, vim.fn.expand '%:p:h')
end, { buffer = true, desc = '[R]un: [B]usted in this dir' })

-- which-key group label (guarded -- ftplugin may load before which-key).
local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add { { '<leader>R', group = '[R]un', buffer = 0 } }
end
