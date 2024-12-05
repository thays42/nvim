-- Helper for creating terminal commands
local Terminal = require("toggleterm.terminal").Terminal

local function q2quit(term)
  vim.cmd("startinsert!")
  vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
end

-- Add terminal definitions here.
function ToggleFloatTerm(cmd, dir, close_on_exit)
  if close_on_exit == nil then
    close_on_exit = true
  end
  Terminal:new({
    cmd = cmd,
    dir = dir,
    direction = "float",
    on_open = q2quit,
    on_close = function(term)
      vim.cmd("startinsert!")
    end,
    close_on_exit = close_on_exit,
  }):toggle()
end

-- Add terminal definitions here.
function ToggleRepl(cmd, dir)
  Terminal:new({
    cmd = cmd,
    dir = dir,
    direction = "horizontal",
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
    on_close = function(term)
      vim.cmd("startinsert!")
    end,
  }):toggle()
end

function ToggleRInterpreter(dir)
  ToggleRepl('R', dir)
  opts = { buffer = 0 }
  vim.keymap.set('t', '<C-w>', [[<Cmd>wincmd p<CR>]], opts)
  vim.keymap.set('t', '<C-b><C-l>', [[devtools::load_all()<CR>]], opts)
  vim.keymap.set('t', '<C-b><C-d>', [[roxygen2::roxygenize()<CR>]], opts)
  vim.keymap.set('t', '<C-q><C-q>', [[q(save="no")<CR>]], opts)
end

vim.api.nvim_set_keymap(
  "n",
  "<leader>;g",
  "<cmd>lua ToggleFloatTerm('lazygit', 'git_dir')<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>;h", "<cmd>lua ToggleFloatTerm('htop')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;rr", "<cmd>lua ToggleRInterpreter()<CR>", { noremap = true, silent = true })
