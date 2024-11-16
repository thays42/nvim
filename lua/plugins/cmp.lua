return {
  -- Completion engine
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },

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
      snippetDir = "./snippets",
    }
  },
}
