-- lean.nvim — Lean 4 theorem prover support
--
-- lean.nvim manages the Lean language server itself, so it is NOT added to
-- lua/lsp/servers.lua. Your existing LspAttach autocmd (lua/lsp/init.lua) still
-- provides the generic gr* navigation maps once the Lean client attaches.
--
-- Prerequisite: the Lean toolchain (elan/lake) provides the language server.
-- It does NOT come from pacman:
--   curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
-- Then start a project with mathlib (optional, for learning):
--   lake +stable new myproj math
--
-- Usage notes:
--   - Infoview opens automatically: live goal/term/tactic state.
--   - Unicode abbreviations expand in insert mode: \to → →, \alpha → α, etc.
--   - Default lean.nvim mappings are under <LocalLeader> (backslash).

return {
  'Julian/lean.nvim',
  ft = 'lean',
  event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
  dependencies = {
    'nvim-telescope/telescope.nvim', -- enables Lean-specific pickers
  },
  ---@type lean.Config
  opts = {
    mappings = true,
    lsp = {
      capabilities = require('blink.cmp').get_lsp_capabilities(),
    },
    infoview = {
      autoopen = true,
    },
  },
}
