-- LSP Server Configurations
-- Servers must be installed via your system package manager
--
-- Arch Linux:
--   pacman -S gopls lua-language-server
--
-- To add a new server:
--   1. Install it via your package manager
--   2. Add its configuration below

return {
  -- Go
  -- Install: pacman -S gopls
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },

  -- Lua (for Neovim config and Love2D)
  -- Install: pacman -S lua-language-server
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        hint = {
          enable = true,
          paramName = 'Literal',
          paramType = true,
          setType = true,
          arrayIndex = 'Disable',
        },
        -- Uncomment to silence noisy missing-fields warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },

  -- R
  -- Install in each renv project: renv::install("languageserver")
  -- Or globally: R -e 'install.packages("languageserver", repos="https://cloud.r-project.org")'
  r_language_server = {
    cmd = { 'R', '--slave', '-e', 'languageserver::run()' },
    filetypes = { 'r', 'rmd' },
    root_markers = { '.git', '.Rproj' },
    -- Disable styler formatting (use air via conform.nvim instead)
    capabilities = {
      documentFormattingProvider = false,
      documentRangeFormattingProvider = false,
    },
  },

  -- Add more servers here as needed:
  --
  -- Python (pyright):
  --   Install: pacman -S pyright
  --   pyright = {},
  --
  -- TypeScript (ts_ls):
  --   Install: npm install -g typescript typescript-language-server
  --   ts_ls = {},
  --
  -- Rust (rust_analyzer):
  --   Install: pacman -S rust-analyzer
  --   rust_analyzer = {},
}
