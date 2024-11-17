vim.api.nvim_set_keymap(
  "n",
  "<leader>;b",
  "<cmd>lua ToggleFloatTerm('go run ' .. vim.fn.expand('%'), nil, false)<CR>",
  { noremap = true, silent = true }
)

vim.api.nvim_set_keymap(
  "n",
  "<leader>;t",
  "<cmd>lua ToggleFloatTerm('go test', vim.fn.expand('%:p:h'), false)<CR>",
  { noremap = true, silent = true }
)
