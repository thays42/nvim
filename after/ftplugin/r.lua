-- Toggleterm
vim.api.nvim_buf_set_keymap(0, "n", "<enter>", "vas:ToggleTermSendVisualSelection<cr>`>]s", {})
vim.api.nvim_buf_set_keymap(0, "v", "<enter>", "<cmd>ToggleTermSendVisualSelection<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>;rr", "<cmd>lua ToggleRepl('R')<CR>", { noremap = true, silent = true })
