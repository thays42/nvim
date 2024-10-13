-- auto-completion engine
return {
  "hrsh7th/nvim-cmp",
  event = "VeryLazy",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "onsails/lspkind-nvim",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-omni",
    "R-nvim/cmp-r",
  },
  config = function()
    -- Setup nvim-cmp.
    local cmp = require("cmp")
    local lspkind = require("lspkind")

    cmp.setup {
      mapping = cmp.mapping.preset.insert {
        ["<Tab>"] = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end,
        ["<S-Tab>"] = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end,
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ["<C-e>"] = cmp.mapping.abort(),
        ["<Esc>"] = cmp.mapping.close(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
      },
      sources = {
        { name = "nvim_lsp" }, -- For nvim-lsp
        { name = "path" }, -- for path completion
        { name = "buffer", keyword_length = 2 }, -- for buffer word completion
        { name = "cmp_r" }, -- For R
      },
      completion = {
        keyword_length = 1,
        completeopt = "menu,noselect",
      },
      view = {
        entries = "custom",
      },
      formatting = {
        format = lspkind.cmp_format {
          mode = "symbol_text",
          menu = {
            nvim_lsp = "[LSP]",
            path = "[Path]",
            buffer = "[Buffer]",
            emoji = "[Emoji]",
            omni = "[Omni]",
            cmp_r = "[R]",
          },
          show_labelDetails = true,
          maxwidth = 40,
          ellipsis_char = "...",
        },
      },
    }

    vim.cmd([[
      highlight! link CmpItemMenu Comment
      " gray
      highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
      " blue
      highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
      highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
      " light blue
      highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
      " pink
      highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
      highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
      " front
      highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
      highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
      highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
    ]])

    require("cmp_r").setup({})
  end,
}
