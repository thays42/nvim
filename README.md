# Neovim Configuration

Personal Neovim configuration (0.11+) managed with lazy.nvim. Designed for R package development, Go, Lua, and markdown editing. Symlinked to `~/.config/nvim`.

## Theme

Gruvbox dark with a pure black (`#000000`) background — a vitesse-style variation. Hard contrast, no italics.

## Plugin Manager

[lazy.nvim](https://github.com/folke/lazy.nvim) — plugins live in `lua/plugins/` as individual spec files that are auto-loaded.

## Plugins

### Core Editor

| Plugin | Purpose |
|--------|---------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting, incremental selection, textobjects |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Function, class, argument, loop, conditional text objects |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Autocompletion (LSP, paths, snippets) with signature help |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine, loads VSCode-style snippets from `.vscode/` |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Format-on-save (stylua, gofmt/goimports, air) |
| [flash.nvim](https://github.com/folke/flash.nvim) | Fast motion — `s` to jump, `S` for treesitter select |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | File explorer — edit the filesystem like a buffer (`-` to open) |
| [mini.surround](https://github.com/echasnovski/mini.surround) | Add/change/delete surrounding pairs |
| [mini.ai](https://github.com/echasnovski/mini.ai) | Extended text objects |
| [mini.statusline](https://github.com/echasnovski/mini.statusline) | Lightweight statusline |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets and quotes |
| [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim) | Detect tabstop/shiftwidth automatically |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indent guides |
| [undotree](https://github.com/mbbill/undotree) | Undo history visualization (`<leader>u`) |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding hints on partial input |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and search TODO/FIXME/HACK comments |
| [persistence.nvim](https://github.com/folke/persistence.nvim) | Session save/restore per working directory |
| [cheatsheet.nvim](https://github.com/sudormrfbin/cheatsheet.nvim) | Fuzzy-searchable cheatsheet (`<leader>?`) |

### Telescope

[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) with extensions:

- **fzf-native** — fast native sorter
- **ui-select** — use Telescope for `vim.ui.select`
- **heading** — search markdown headings (`<leader>sm`)
- **r_help** — search R documentation (`<leader>sR`)

### Git

| Plugin | Purpose |
|--------|---------|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Gutter signs, hunk stage/reset/preview, blame |
| [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) | LazyGit TUI inside Neovim (`<leader>gg`) |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Diff and merge tool |

### LSP

Native `vim.lsp.config` (Neovim 0.11+) — no Mason. Servers are installed via the system package manager and configured in `lua/lsp/servers.lua`.

| Plugin | Purpose |
|--------|---------|
| [fidget.nvim](https://github.com/j-hui/fidget.nvim) | LSP progress indicator |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Neovim Lua API + Love2D completions for lua_ls |

### Debugging

[nvim-dap](https://github.com/mfussenegger/nvim-dap) with:

- **nvim-dap-ui** — debugger UI panels
- **nvim-dap-virtual-text** — inline variable values
- **nvim-dap-go** — Go debugging via Delve

### Testing

| Plugin | Purpose |
|--------|---------|
| [neotest](https://github.com/nvim-neotest/neotest) | Test runner framework with summary, output, watch mode |
| [nvim-coverage](https://github.com/andythigpen/nvim-coverage) | Coverage signs in gutter, summary, navigation |

Custom local adapters (in `lua/`):

- **neotest-testthat** — R testthat adapter (local, upstream abandoned)
- **coverage-r** — R coverage via covr/cobertura XML, with uncovered-line navigation and Telescope picker

### Database

| Plugin | Purpose |
|--------|---------|
| [vim-dadbod](https://github.com/tpope/vim-dadbod) | Database client (PostgreSQL, SQLite, MySQL) |
| [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | Database browser UI (`<leader>db`) |
| [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion) | SQL completions |

### Markdown

| Plugin | Purpose |
|--------|---------|
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Inline markdown rendering (`<leader>tm` to toggle) |
| [follow-md-links.nvim](https://github.com/jghauser/follow-md-links.nvim) | Follow internal and external markdown links |

### Other

| Plugin | Purpose |
|--------|---------|
| [love2d.nvim](https://github.com/S1M0N38/love2d.nvim) | Run Love2D games (`<leader>lr`) |

## Language-Specific Setup

### R Development

**LSP:** `r_language_server` — install per renv project with `renv::install("languageserver")`. Pin lintr to 3.1.2 (`renv::install("lintr@3.1.2")`) to avoid breaking changes in 3.3.0+.

**Formatting:** [air](https://github.com/posit-dev/air) (Posit's Rust-based R formatter) via conform.nvim with format-on-save.

**REPL:** [R.nvim](https://github.com/R-nvim/R.nvim) with radian console. Key workflow:

| Key | Action |
|-----|--------|
| `\rf` | Start R console |
| `\rq` | Quit R console |
| `Enter` | Send line/selection to R |
| `<leader>;` | Toggle focus between code and R terminal |
| `<leader>z` | Zoom/unzoom window |
| `\ro` | Toggle object browser |
| `\rh` | R help |
| `\rv` | View data frame (csvlens) |

**Package development:**

| Key | Action |
|-----|--------|
| `\rT` | `devtools::test()` |
| `\rt` | `devtools::test_file()` (current file) |
| `\rd` | `devtools::document()` |
| `\rl` | `devtools::load_all()` |

**Debugging:** browser()-based (no DAP support for R). Insert `browser()` or use `\bg` to `debug()` a function, then step through in the R console (`n`, `s`, `c`, `Q`).

| Key | Action |
|-----|--------|
| `\bg` | `debug()` function under cursor |
| `\ud` | `undebug()` function |
| `\dl` | List variables in frame |
| `\de` | `ls.str()` in frame |
| `\dw` | Show call stack |

**Testing & coverage:**

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test (neotest) |
| `<leader>tf` | Run test file |
| `<leader>ta` | Run all tests |
| `<leader>ts` | Toggle test summary |
| `<leader>tc` | Toggle coverage signs |
| `<leader>tg` | Generate coverage report (covr) |
| `<leader>tu` | Pick uncovered functions (Telescope) |
| `]u` / `[u` | Next/previous uncovered line |

### Go

**LSP:** `gopls` with staticcheck, unusedparams analysis, gofumpt formatting.

**Formatting:** `gofmt` + `goimports` via conform.nvim.

**Debugging:** nvim-dap with Delve (`<leader>dt` to debug test under cursor).

### Lua (Neovim Config / Love2D)

**LSP:** `lua_ls` with inlay hints, call snippet completion. lazydev.nvim provides Neovim API and Love2D library completions.

**Formatting:** StyLua (160 char width, 2-space indent, single quotes). Run `stylua .` or format-on-save.

### Markdown

- Inline rendering with render-markdown.nvim (`<leader>tm` to toggle)
- Follow links with follow-md-links.nvim
- Search headings with `<leader>sm`
- **Review threads:** A custom review system (`lua/review.lua`) for embedding authored review threads in markdown files as HTML comments. Threads are identified by the `<!--REVIEW:` prefix (distinct from regular HTML comments) and contain `@thays:` / `@claude:` authored notes:

  ```html
  <!--REVIEW:open 2026-02-26
  @thays: This section needs a clearer explanation
  @claude: Agreed, a pros/cons list would help
  @thays: Let's do that
  -->
  ```

  `@thays:` tags are highlighted blue, `@claude:` tags orange, and block markers purple.

  **CLAUDE.md snippet** — add this to projects where you use review threads so Claude follows the convention:

  ```markdown
  ## Review Notes

  Review threads are HTML comments prefixed with `<!--REVIEW:`. They are distinct from regular HTML comments.

  <!--REVIEW:open 2026-02-26
  @thays: question or comment
  @claude: response
  -->

  - `@thays:` = human notes, `@claude:` = your notes
  - When responding to a review thread, append a `@claude:` line before the closing `-->`
  - Do not modify or remove `@thays:` lines
  - Do not resolve threads (change `open` to `closed`) unless asked
  ```

| Key | Action |
|-----|--------|
| `<leader>rn` | New review note (creates thread or appends to existing) |
| `<leader>rl` | List open review threads (quickfix) |
| `<leader>rr` | Resolve review thread under cursor |
| `<leader>rc` | Clear resolved threads from buffer |
| `<leader>rC` | Clear resolved threads from all .md files |
| `]r` / `[r` | Next/previous review thread |
| `<leader>sv` | Search open review threads (Telescope) |

### Database

Open the database UI with `<leader>db`. Connections can be set via `DATABASE_URL` environment variable. Includes table helpers for PostgreSQL, SQLite, and MySQL (preview rows, count).

## Key Mappings Overview

**Leader:** `Space` | **Local leader:** `\`

### General

| Key | Action |
|-----|--------|
| `jk` | Escape insert mode |
| `<Esc>` | Clear search highlight |
| `<leader>w` | Write file |
| `<leader>x` | Save and close |
| `<leader>;` | Toggle to last window |
| `<leader>z` | Zoom/unzoom window |
| `Alt+j/k` | Move line(s) up/down |
| `Ctrl+d/u` | Scroll down/up (centered) |
| `Ctrl+h/j/k/l` | Window navigation |
| `<Esc><Esc>` | Exit terminal mode |

### Search (Telescope)

| Key | Action |
|-----|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep current word |
| `<leader>s.` | Recent files |
| `<leader><leader>` | Open buffers |
| `<leader>/` | Fuzzy search in buffer |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>sd` | Diagnostics |
| `<leader>sr` | Resume last search |
| `<leader>sn` | Neovim config files |
| `<leader>st` | Search TODOs |

### LSP

| Key | Action |
|-----|--------|
| `grd` | Go to definition |
| `grD` | Go to declaration |
| `grr` | Go to references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `grn` | Rename |
| `gra` | Code action |
| `<leader>th` | Toggle inlay hints |

### Treesitter Textobjects

Selection: `af`/`if` (function), `ac`/`ic` (class), `aa`/`ia` (argument), `ai`/`ii` (conditional), `al`/`il` (loop).

Navigation: `]f`/`[f` (function), `]c`/`[c` (class), `]a`/`[a` (argument).

Swap: `<leader>a` / `<leader>A` (swap argument forward/backward).

Incremental selection: `gnn` to start, `+` to expand, `-` to shrink.

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit |
| `]c` / `[c` | Next/previous git change |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff against index |
| `<leader>tb` | Toggle line blame |

### Debug (DAP)

| Key | Action |
|-----|--------|
| `<leader>dc` | Start/continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>du` | Toggle debug UI |
| `<leader>dt` | Debug Go test |

## Structure

```
nvim/
├── init.lua                    # Bootstrap lazy.nvim, load modules
├── lua/
│   ├── options.lua             # Global vim options
│   ├── keymaps.lua             # Global keybindings
│   ├── review.lua              # Markdown review comment system
│   ├── plugins/                # Plugin specs (one file per domain)
│   │   ├── ui.lua              # Theme, oil, statusline, indent guides
│   │   ├── editor.lua          # Treesitter, textobjects, surround, which-key
│   │   ├── telescope.lua       # Telescope + extensions
│   │   ├── navigation.lua      # Flash, persistence
│   │   ├── completion.lua      # blink.cmp, LuaSnip, lazydev, conform
│   │   ├── lsp.lua             # fidget.nvim
│   │   ├── git.lua             # gitsigns, lazygit
│   │   ├── debug.lua           # nvim-dap + UI + Go adapter
│   │   ├── testing.lua         # neotest, nvim-coverage
│   │   ├── markdown.lua        # render-markdown, follow-md-links
│   │   ├── r.lua               # R.nvim
│   │   ├── database.lua        # dadbod + UI
│   │   ├── diffs.lua           # diffview
│   │   ├── love2d.lua          # Love2D runner
│   │   └── cheatsheet.lua      # Cheatsheet
│   ├── lsp/
│   │   ├── init.lua            # LSP setup, keymaps, diagnostics
│   │   └── servers.lua         # Server configs (gopls, lua_ls, r_language_server)
│   ├── coverage-r/             # Custom R coverage module for nvim-coverage
│   └── neotest-testthat/       # Custom R testthat adapter for neotest
├── .stylua.toml                # StyLua config
└── cheatsheet.txt              # Custom cheatsheet entries
```

## Requirements

- Neovim 0.11+
- Nerd Font
- System packages: `gopls`, `lua-language-server`, `stylua`, `lazygit`, `csvlens`
- Go: `delve` (`go install github.com/go-delve/delve/cmd/dlv@latest`)
- R: `languageserver` package (per renv project), `air` formatter, `radian` console
- Build tools: `make` (for telescope-fzf-native)
