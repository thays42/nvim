local M = {}

local function today()
  return os.date '%Y-%m-%d'
end

--- Insert a new open review block at the cursor.
function M.new()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local date = today()
  vim.api.nvim_buf_set_lines(0, row, row, false, {
    '<!--REVIEW:open ' .. date,
    '',
    '-->',
  })
  -- Position cursor on the blank line and enter insert mode
  vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  vim.cmd 'startinsert'
end

--- Grep for open review threads and populate the quickfix list.
function M.list()
  vim.cmd 'vimgrep /<!--REVIEW:open/j **/*.md'
  vim.cmd 'copen'
end

--- Resolve the review block enclosing the cursor (open -> closed).
function M.resolve()
  local line = vim.fn.search('<!--REVIEW:open', 'bnWc')
  if line == 0 then
    vim.notify('No open review block found above cursor', vim.log.levels.WARN)
    return
  end
  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  local new_text = text:gsub('<!--REVIEW:open', '<!--REVIEW:closed')
  vim.api.nvim_buf_set_lines(0, line - 1, line, false, { new_text })
  vim.notify('Review resolved', vim.log.levels.INFO)
end

--- Remove all closed review blocks from the current buffer.
function M.clear()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local result = {}
  local skipping = false
  local removed = 0

  for _, line in ipairs(lines) do
    if not skipping and line:match '<!--REVIEW:closed' then
      skipping = true
      removed = removed + 1
    elseif skipping and line:match '^%-%->' then
      skipping = false
    elseif not skipping then
      table.insert(result, line)
    end
  end

  if removed == 0 then
    vim.notify('No closed review blocks found', vim.log.levels.INFO)
    return
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
  vim.notify('Removed ' .. removed .. ' closed review block(s)', vim.log.levels.INFO)
end

--- Remove all closed review blocks from all *.md files in cwd.
function M.clear_all()
  local files = vim.fn.globpath('.', '**/*.md', false, true)
  local total = 0

  for _, filepath in ipairs(files) do
    local content = vim.fn.readfile(filepath)
    local result = {}
    local skipping = false
    local removed = 0

    for _, line in ipairs(content) do
      if not skipping and line:match '<!--REVIEW:closed' then
        skipping = true
        removed = removed + 1
      elseif skipping and line:match '^%-%->' then
        skipping = false
      elseif not skipping then
        table.insert(result, line)
      end
    end

    if removed > 0 then
      vim.fn.writefile(result, filepath)
      total = total + removed
    end
  end

  vim.notify('Removed ' .. total .. ' closed review block(s) from project', vim.log.levels.INFO)
end

-- Commands
vim.api.nvim_create_user_command('ReviewNew', M.new, { desc = 'Insert new review block' })
vim.api.nvim_create_user_command('ReviewList', M.list, { desc = 'List open review threads in quickfix' })
vim.api.nvim_create_user_command('ReviewNext', 'cnext', { desc = 'Next review thread' })
vim.api.nvim_create_user_command('ReviewPrev', 'cprev', { desc = 'Previous review thread' })
vim.api.nvim_create_user_command('ReviewResolve', M.resolve, { desc = 'Resolve enclosing review block' })
vim.api.nvim_create_user_command('ReviewClear', M.clear, { desc = 'Remove closed reviews from buffer' })
vim.api.nvim_create_user_command('ReviewClearAll', M.clear_all, { desc = 'Remove closed reviews from all md files' })

-- Keymaps
local map = vim.keymap.set
map('n', '<leader>rn', M.new, { desc = '[R]eview [N]ew' })
map('n', '<leader>rl', M.list, { desc = '[R]eview [L]ist' })
map('n', ']r', '<cmd>cnext<CR>', { desc = 'Next review thread' })
map('n', '[r', '<cmd>cprev<CR>', { desc = 'Previous review thread' })
map('n', '<leader>rr', M.resolve, { desc = '[R]eview [R]esolve' })
map('n', '<leader>rc', M.clear, { desc = '[R]eview [C]lear buffer' })
map('n', '<leader>rC', M.clear_all, { desc = '[R]eview [C]lear all files' })

return M
