-- Nerd font support
vim.g.have_nerd_font = true

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Tabs and indentation
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- File handling
vim.o.autoread = true
vim.o.undofile = true
vim.o.confirm = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'

-- UI
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Whitespace display
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Wrapping
vim.o.linebreak = true
vim.o.breakindent = true

-- Clipboard (delayed to avoid startup slowdown)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
