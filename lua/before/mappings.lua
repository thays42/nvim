-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode and window swap" })
vim.keymap.set("n", "<A-h>", "<C-w><", { desc = "Decrease window width" })
vim.keymap.set("n", "<A-l>", "<C-w>>", { desc = "Increase window width" })
vim.keymap.set("n", "<A-j>", "<C-w>+", { desc = "Increase window height" })
vim.keymap.set("n", "<A-k>", "<C-w>-", { desc = "Decrease Window height" })
vim.keymap.set("n", "<leader>wj", "<C-w>J", { desc = "Move window down" })
vim.keymap.set("n", "<leader>wk", "<C-w>K", { desc = "Move window up" })
vim.keymap.set("n", "<leader>wh", "<C-w>H", { desc = "Move window right" })
vim.keymap.set("n", "<leader>wl", "<C-w>L", { desc = "Move window left" })
vim.keymap.set("n", "<leader>ww", [[<C-w><C-p>]], { desc = "Switch to previous window" })

-- Traveling lines
vim.keymap.set("n", "<C-[>", ":m -2<cr>")
vim.keymap.set("n", "<C-]>", ":m +1<cr>")

-- Buffers
vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Switch to previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "[B]uffer [D]elete" })
vim.keymap.set("n", "<leader>bj", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bk", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Easy insert to normal mode
vim.keymap.set("i", "jk", "<Esc>", {})

-- Plug-in Mappings
vim.keymap.set("n", "<leader>mk", "<cmd>MakeitOpen<cr>", { desc = "Makeit Open" })
vim.keymap.set("n", "<leader>ml", "<cmd>MakeitRedo<cr>", { desc = "Makeit Redo" })
vim.keymap.set("n", "<leader>mo", "<cmd>MakeitToggleResults<cr>", { desc = "Makeit Toggle Results" })
vim.keymap.set("n", "<leader>mn", "<cmd>MakeitStop<cr>", { desc = "Makeit Stop" })
