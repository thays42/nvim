-- Toggleterm
vim.api.nvim_buf_set_keymap(0, "n", "<enter>", "vas:ToggleTermSendVisualSelection<cr>`>]s", {})
vim.api.nvim_buf_set_keymap(0, "v", "<enter>", "<cmd>ToggleTermSendVisualSelection<cr>", {})


function ToggleRInterpreter(dir)
  ToggleRepl('R', dir)
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<C-w>', [[<Cmd>wincmd p<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[devtools::load_all()<CR>]], opts)
  vim.keymap.set('t', '<C-d>', [[roxygen2::roxygenize()<CR>]], opts)
  vim.keymap.set('t', '<C-q><C-q>', [[q(save="no")<CR>]], opts)
end

function ToggleRadianInterpreter(dir)
  ToggleRepl('radian', dir)
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<C-w>', [[<Cmd>wincmd p<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[devtools::load_all()<CR>]], opts)
  vim.keymap.set('t', '<C-d>', [[roxygen2::roxygenize()<CR>]], opts)
  vim.keymap.set('t', '<C-q><C-q>', [[q(save="no")<CR>]], opts)
end

function ToggleRTestActiveFile()
  local cmd = "R --quiet --no-save --no-restore -e 'devtools::test_active_file(\"" ..
      vim.fn.expand("%") .. "\", reporter=\"tap\")'"
  ToggleFloatTerm(cmd, nil, false)
end

vim.api.nvim_set_keymap("n", "<leader>;rr", "<cmd>lua ToggleRInterpreter()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;ra", "<cmd>lua ToggleRadianInterpreter()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;rt", "<cmd>lua ToggleRTestActiveFile()<CR>", { noremap = true, silent = true })
