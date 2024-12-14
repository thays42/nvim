-- Snippets
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })

local ls = require("luasnip")

vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })


vim.keymap.set("n", "<leader>se", function() require("scissors").editSnippet() end, { desc = "[S]nippet [E]dit" })

-- when used in visual mode, prefills the selection as snippet body
vim.keymap.set({ "n", "x" }, "<leader>sa", function() require("scissors").addNewSnippet() end,
  { desc = "[S]nippet [A]dd" })
