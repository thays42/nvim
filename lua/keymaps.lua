local map = vim.keymap.set

-- Better line navigation (respects wrapped lines)
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-- Escape insert mode
map('i', 'jk', '<Esc>')

-- Clear search highlight
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Save and quit
map('n', '<leader>w', '<cmd>w<CR>', { desc = '[W]rite file' })
map('n', '<leader>x', '<cmd>x<CR>', { desc = 'Save and close' })

-- Toggle to last window (useful for R code ↔ R terminal)
map('n', '<leader>;', '<C-w>p', { desc = 'Toggle to last window' })

-- Zoom/unzoom current window (like tmux zoom)
-- Uses tabs to properly save/restore window layout
map('n', '<leader>z', function()
  if vim.fn.winnr '$' == 1 then
    if vim.fn.tabpagenr '$' > 1 and vim.fn.tabpagewinnr(vim.fn.tabpagenr(), '$') == 1 then
      -- We're zoomed (alone in a tab), close tab to unzoom
      vim.cmd 'tabclose'
    end
  else
    -- Multiple windows, zoom current one to new tab
    vim.cmd 'tab split'
  end
end, { desc = 'Toggle window [Z]oom' })

-- Move lines up/down
map('n', '<A-j>', '<cmd>m .+1<CR>==', { desc = 'Move line down' })
map('n', '<A-k>', '<cmd>m .-2<CR>==', { desc = 'Move line up' })
map('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Centered scrolling
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down centered' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up centered' })

-- Keep cursor position when joining lines
map('n', 'J', 'mzJ`z', { desc = 'Join lines (keep cursor)' })

-- Stay in visual mode when indenting
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })

-- Diagnostic navigation
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous [D]iagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next [D]iagnostic' })

-- Diagnostic quickfix
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Terminal escape
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
