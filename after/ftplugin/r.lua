-- Jobs
function ToggleRTestActiveFile()
  local cmd = "R --quiet --no-save --no-restore -e 'devtools::test_active_file(\"" ..
      vim.fn.expand("%") .. "\", reporter=\"tap\")'"
  ToggleFloatTerm(cmd, nil, false)
end

vim.api.nvim_set_keymap("n", "<leader>;rt", "<cmd>lua ToggleRTestActiveFile()<CR>", { noremap = true, silent = true })

-- Repl
vim.api.nvim_set_keymap("n", "<leader>;rr", "<cmd>:ReplToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;rl", "<cmd>:ReplSendArgs devtools::load_all()<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;rd", "<cmd>:ReplSendArgs devtools::document()<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<enter>", "vas",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<enter>", "<Plug>(ReplSendVisual)",
  { noremap = true, silent = true })
