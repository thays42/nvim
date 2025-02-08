return {
  -- Completion engine
  {
    'saghen/blink.cmp',
    lazy = false,
    version = '*',
    --    build = "cargo build --release",
    dependencies = 'L3MON4D3/LuaSnip',
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' }
      },

      snippets = { preset = 'luasnip' },
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
