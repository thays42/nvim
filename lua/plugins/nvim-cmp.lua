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
    require("config.nvim-cmp")
    require("cmp_r").setup({})
  end,
}
