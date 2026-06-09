# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Neovim configuration. Symlinked to `~/.config/nvim`.

## Theme

Vitesse (`ptdewey/vitesse-nvim`) forced to a pure black background (#000000).
A `ColorScheme` autocmd in `lua/plugins/ui.lua` (augroup `PureBlackBg`) overrides
the background of `Normal`/`NormalFloat`/`SignColumn`/`LineNr`/`CursorLineNr`/`FoldColumn`
to `#000000` under whichever colorscheme is active (Vitesse's own default is #121212).
Switch/preview themes live with `<leader>sc` (Telescope colorscheme picker).

## Lua Formatting

Lua files use StyLua. Configuration is in `.stylua.toml`:
- 160 character line width
- 2-space indentation
- Single quotes preferred
- No call parentheses

Format: `stylua .`
Check: `stylua --check .`

## Structure

```
nvim/
├── init.lua           # Bootstrap lazy.nvim, load modules
├── lua/
│   ├── options.lua    # Global vim options
│   ├── keymaps.lua    # Global keybindings
│   ├── plugins/       # Plugin specs (lazy.nvim)
│   └── lsp/
│       ├── init.lua   # LSP setup, keymaps, diagnostics
│       └── servers.lua# Server configs (gopls, lua_ls)
```

- Leader: Space
- Plugin manager: lazy.nvim
- LSP: Native vim.lsp.config (Neovim 0.11+), no Mason
- Completion: blink.cmp with LuaSnip
- Formatting: conform.nvim with format-on-save
- File explorer: oil.nvim
- Navigation: flash.nvim

## Adding Plugins

Add files to `lua/plugins/` returning a lazy.nvim spec table.

## Adding LSPs

1. Install via pacman (no Mason)
2. Add to `lua/lsp/servers.lua` with `cmd`, `filetypes`, `root_markers`

## Rust Development

Configured in `lua/plugins/rust.lua`.

**Toolchain:** Installed via rustup (`rustc`, `cargo`, `rustfmt`, `rust-analyzer`).

**LSP:** Managed by **rustaceanvim**, NOT `lua/lsp/servers.lua` — do not add `rust_analyzer` there, it would start twice and conflict. Settings (clippy on check, `allFeatures`) live in the `vim.g.rustaceanvim` table in `rust.lua`.

**Version pin:** rustaceanvim is pinned to `^6` (requires Neovim 0.12+, which we're on). Bump the major to match if a future rustaceanvim raises its Neovim floor again.

**Formatting:** rustfmt via conform.nvim with format-on-save.

**Debugging:** Works via `lldb-dap` (install: `sudo dnf install lldb`). The standard `<leader>d*` debug keymaps drive it; `<leader>Rd` lists debuggable targets.

**Tests:** Run through the existing neotest UI via rustaceanvim's built-in adapter (no `cargo-nextest` needed). Same `<leader>t*` keymaps as other languages.

**Cargo.toml:** crates.nvim provides version completion, "newer version" hints, hover, and code actions via an in-process LSP — so completion flows through blink's `lsp` source and the normal LSP keymaps (`gra`, `K`).

**Keymaps** (buffer-local in Rust files, `<leader>R` = "[R]ust"):
- `<LocalLeader>` n/a — Rust uses `<Leader>R`, not LocalLeader
- `<Leader>Rr` - Runnables (pick cargo run / a test / etc.)
- `<Leader>Rd` - Debuggables
- `<Leader>Rm` - Expand macro
- `<Leader>Re` - Explain error
- `<Leader>Rc` - Open Cargo.toml
- `<Leader>Rp` - Go to parent module
- `K` - Hover actions (rustaceanvim's richer hover)
- `gra` - Grouped code actions

## R Development

**R Language Server:**
Install in each renv project:
```r
renv::install("languageserver")
renv::install("lintr@3.1.2")  # Must pin to 3.1.2
```

**Important:** lintr 3.3.0+ breaks languageserver 0.3.16 due to `parse_settings` changes. Always pin lintr to 3.1.2 until languageserver is updated.

**Linting:** Configure via `.lintr` file in project root:
```
linters: linters_with_defaults(
    line_length_linter = line_length_linter(120),
    object_usage_linter = NULL
  )
encoding: "UTF-8"
```

**Formatting:** Uses air (Posit's Rust-based formatter) via conform.nvim with format-on-save.

**R.nvim:** Interactive R development with REPL and object browser (uses Neovim terminal).
- `<LocalLeader>` (backslash) for R commands
- `<LocalLeader>rf` - Start R console (Neovim terminal split)
- `<LocalLeader>rq` - Quit R console
- `<Enter>` (in normal/visual mode) - Send line/selection to R
- `<Leader>;` - Toggle focus between R code ↔ R terminal
- `<Leader>z` - Zoom/unzoom current window (full screen toggle)
- `<LocalLeader>ro` - Toggle object browser
- `<LocalLeader>rh` - R help

**Package Development:**
- `<LocalLeader>rT` - Run all tests (devtools::test())
- `<LocalLeader>rt` - Test current file
- `<LocalLeader>rd` - Document code (devtools::document())
- `<LocalLeader>rl` - Load all (devtools::load_all())

**Debugging:** R debugging uses browser()-based workflow (no DAP support).

Note: DAP debugging attempted but not viable:
- `debugadapter`: Requires R-devel with browser hooks (too experimental)
- `vscDebugger`: Designed for VS Code extension, doesn't work standalone with nvim-dap

Browser-based debugging workflow:
1. Add `browser()` in your code, or use `<LocalLeader>bg` to debug() a function
2. Run the function in R console
3. When browser() is hit, use these commands in the R console:
   - `n` - execute next line
   - `s` - step into function
   - `c` - continue execution
   - `Q` - quit browser
   - `ls()` - list variables in current frame
   - `where` - show call stack

Helper keybindings (send commands to R console):
- `<LocalLeader>bg` - debug() function under cursor
- `<LocalLeader>ud` - undebug() function under cursor
- `<LocalLeader>dl` - List variables in current debug frame
- `<LocalLeader>de` - List variables with structure (ls.str())
- `<LocalLeader>dw` - Show call stack

While not as visual as DAP, browser() debugging is reliable and works well with the R workflow.
