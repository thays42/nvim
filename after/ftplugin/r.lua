vim.api.nvim_buf_set_keymap(0, "v", "<enter>", "<Plug>ReplSendVisual", { desc = "Send statement" })
vim.api.nvim_buf_set_keymap(0, "n", "<enter>", "vas<cr>`>]s", { desc = "Send statement" })
