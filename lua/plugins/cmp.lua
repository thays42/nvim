return {
  -- Completion engine
  {
    'saghen/blink.cmp',
    lazy = false,
    version = '*',
    build = "cargo build --release",
    dependencies = 'L3MON4D3/LuaSnip',
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'luasnip', 'buffer' }
      },
      snippets = {
        expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
        active = function(filter)
          if filter and filter.direction then
            return require('luasnip').jumpable(filter.direction)
          end
          return require('luasnip').in_snippet()
        end,
        jump = function(direction) require('luasnip').jump(direction) end,
      },
    },
    opts_extend = { "sources.default" }
  },

  -- Snippets
  {
    'L3MON4D3/LuaSnip',
    build = "make install_jsregexp"
  },
  { "saadparwaiz1/cmp_luasnip" },
  {
    "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim",
    opts = {
      snippetDir = vim.fn.stdpath("config") .. "/snippets",
    }
  },
}
