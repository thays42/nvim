return {
  "neovim/nvim-lspconfig",
  event = { "BufRead", "BufNewFile" },
  config = function()
    require("config.lsp")
  end,
}
