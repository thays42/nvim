-- Completions
local cmp = require('cmp')

cmp.setup({
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
  },
  mapping = cmp.mapping.preset.insert({
    -- Navigate between completion items
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
    ['<C-n>'] = function(fallback)
      if cmp.visible() then
        cmp.mapping.select_next_item()
      else
        cmp.complete()
        vim.wait(500, function() return cmp.visible() end)
        cmp.select_next_item()
      end
    end,
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),

    -- Snippet only
    ['<C-s>'] = cmp.mapping.complete({
      config = {
        sources = {
          { name = "luasnip" }
        }
      }
    })
  }),
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  completion = {
    autocomplete = false,
  }
})

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
