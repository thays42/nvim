return {
  "nvim-treesitter/nvim-treesitter",
  enabled = true,
  event = "VeryLazy",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = {
        "python",
        "cpp",
        "lua",
        "vim",
        "json",
        "toml",
        "r",
        "rnoweb",
        "markdown",
        "yaml",
        "vim",
        "vimdoc"
      },
      ignore_install = {},    -- List of parsers to ignore installing
      highlight = {
        enable = true,        -- false will disable the whole extension
        disable = { 'help' }, -- list of language that will be disabled
      },
    }
  end,
}
