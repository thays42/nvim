local M = {}

local function today()
  return os.date '%Y-%m-%d'
end

--- Find the review block enclosing the cursor, if any.
--- Returns (open_line, close_line) 1-indexed, or nil if not inside a block.
local function enclosing_block()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local open_line = vim.fn.search('<!--REVIEW:', 'bnWc')
  if open_line == 0 then
    return nil
  end
  -- Search for closing --> from the open tag line
  local saved = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { open_line, 0 })
  local close_line = vim.fn.search('^-->$', 'nW')
  vim.api.nvim_win_set_cursor(0, saved)
  if close_line == 0 or cur > close_line then
    return nil
  end
  return open_line, close_line
end

--- Insert a new review note. If inside an existing thread, append to it.
--- Otherwise create a new thread.
function M.new()
  local open_line, close_line = enclosing_block()
  if open_line and close_line then
    -- Append a new note before the closing -->
    vim.api.nvim_buf_set_lines(0, close_line - 1, close_line - 1, false, {
      '@thays: ',
    })
    vim.api.nvim_win_set_cursor(0, { close_line, 8 })
    vim.cmd 'startinsert!'
  else
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local date = today()
    vim.api.nvim_buf_set_lines(0, row, row, false, {
      '<!--REVIEW:open ' .. date,
      '@thays: ',
      '-->',
    })
    vim.api.nvim_win_set_cursor(0, { row + 2, 8 })
    vim.cmd 'startinsert!'
  end
end

--- Grep for review threads and populate the quickfix list.
--- @param pattern string vimgrep pattern to search for
local function list_threads(pattern)
  local ok = pcall(vim.cmd, 'vimgrep /' .. pattern .. '/j **/*.md')
  if ok then
    vim.cmd 'copen'
  else
    vim.notify('No review threads found', vim.log.levels.INFO)
  end
end

--- List open review threads.
function M.list_open()
  list_threads '<!--REVIEW:open'
end

--- List all review threads (open and closed).
function M.list()
  list_threads '<!--REVIEW:'
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
vim.api.nvim_create_user_command('ReviewList', M.list, { desc = 'List all review threads in quickfix' })
vim.api.nvim_create_user_command('ReviewListOpen', M.list_open, { desc = 'List open review threads in quickfix' })
vim.api.nvim_create_user_command('ReviewNext', 'cnext', { desc = 'Next review thread' })
vim.api.nvim_create_user_command('ReviewPrev', 'cprev', { desc = 'Previous review thread' })
vim.api.nvim_create_user_command('ReviewResolve', M.resolve, { desc = 'Resolve enclosing review block' })
vim.api.nvim_create_user_command('ReviewClear', M.clear, { desc = 'Remove closed reviews from buffer' })
vim.api.nvim_create_user_command('ReviewClearAll', M.clear_all, { desc = 'Remove closed reviews from all md files' })

-- Highlighting
vim.api.nvim_set_hl(0, 'ReviewBlock', { fg = '#d3869b' }) -- gruvbox hard purple
vim.api.nvim_set_hl(0, 'ReviewThays', { fg = '#458588' }) -- gruvbox hard blue
vim.api.nvim_set_hl(0, 'ReviewClaude', { fg = '#d65d0e' }) -- gruvbox hard orange

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.fn.matchadd('ReviewBlock', '<!--REVIEW:\\S\\+.*')
    vim.fn.matchadd('ReviewBlock', '^-->$')
    vim.fn.matchadd('ReviewThays', '@thays:')
    vim.fn.matchadd('ReviewClaude', '@claude:')
  end,
})

-- Keymaps
local map = vim.keymap.set
map('n', '<leader>rn', M.new, { desc = '[R]eview [N]ew' })
map('n', '<leader>rl', M.list, { desc = '[R]eview [L]ist all' })
map('n', '<leader>ro', M.list_open, { desc = '[R]eview [O]pen threads' })
map('n', ']r', '<cmd>cnext<CR>', { desc = 'Next review thread' })
map('n', '[r', '<cmd>cprev<CR>', { desc = 'Previous review thread' })
map('n', '<leader>rr', M.resolve, { desc = '[R]eview [R]esolve' })
map('n', '<leader>rc', M.clear, { desc = '[R]eview [C]lear buffer' })
map('n', '<leader>rC', M.clear_all, { desc = '[R]eview [C]lear all files' })

return M
