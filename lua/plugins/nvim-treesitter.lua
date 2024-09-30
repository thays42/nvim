return {
  "nvim-treesitter/nvim-treesitter",
  enabled = true,
  event = "VeryLazy",
  build = ":TSUpdate",
  config = function()
    require("config.treesitter")
  end,
}
