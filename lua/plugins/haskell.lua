-- Haskell tooling
--
-- haskell-tools.nvim manages haskell-language-server itself (LSP, hover
-- actions, code lenses, GHCi repl, Hoogle). Do NOT also configure an `hls`
-- entry in lua/lsp/servers.lua -- starting it twice conflicts. Same pattern as
-- rustaceanvim (rust.lua) and lean.nvim (lean.lua).
--
-- Toolchain (via ghcup): ghc, cabal, haskell-language-server-wrapper.
-- The wrapper must be on $PATH; it selects the HLS build matching each
-- project's GHC. Install:
--   ghcup install ghc recommended --set
--   ghcup install cabal recommended --set
--   ghcup install hls recommended --set
--
-- Formatting: fourmolu via conform.nvim (see completion.lua). HLS is also told
-- to use fourmolu so any LSP-driven formatting stays consistent.
--
-- Config lives in vim.g.haskell_tools, set BEFORE the plugin loads (init),
-- exactly like vim.g.rustaceanvim.

return {
  'mrcjkb/haskell-tools.nvim',
  version = '^10', -- v10 requires Neovim 0.10+, we're on 0.12
  lazy = false, -- the plugin handles its own lazy-loading on the haskell filetype
  init = function()
    local ok_blink, blink = pcall(require, 'blink.cmp')

    vim.g.haskell_tools = {
      hls = {
        -- Match the completion capabilities used by every other server
        capabilities = ok_blink and blink.get_lsp_capabilities() or nil,

        default_settings = {
          haskell = {
            formattingProvider = 'fourmolu',
          },
        },

        on_attach = function(_, bufnr)
          local ht = require 'haskell-tools'
          local map = function(keys, fn, desc, mode)
            vim.keymap.set(mode or 'n', keys, fn, { buffer = bufnr, desc = 'Haskell: ' .. desc })
          end

          -- Haskell-specific actions, grouped under <leader>H ([H]askell)
          map('<leader>Hs', ht.hoogle.hoogle_signature, 'Hoogle [s]ignature search')
          map('<leader>He', ht.lsp.buf_eval_all, '[E]valuate all code snippets')
          map('<leader>Hc', vim.lsp.codelens.run, 'Run [c]ode lens')
          map('<leader>Hr', ht.repl.toggle, 'Toggle GHCi [r]epl (package)')
          map('<leader>Hf', function()
            ht.repl.toggle(vim.api.nvim_buf_get_name(0))
          end, 'Toggle GHCi repl (current [f]ile)')
          map('<leader>Hq', ht.repl.quit, '[Q]uit GHCi repl')
          map('<leader>Hl', ht.log.nvim_open_hls_logfile, 'Open HLS [l]ogs')

          local ok, wk = pcall(require, 'which-key')
          if ok then
            wk.add { { '<leader>H', group = '[H]askell', buffer = bufnr } }
          end
        end,
      },
    }
  end,
}
