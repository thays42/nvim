# VSCode Transition Design

Transition from Neovim to VSCode + VSCodeVim extension, preserving muscle memory and workflows.

## Goal

Generate VSCode config files (`settings.json`, `keybindings.json`) and a reference guide that recreate the Neovim experience for Markdown, Go, and Rust workflows. Cannot use the VSCode Neovim extension — must use VSCodeVim.

## Extensions

| Extension | ID | Replaces |
|-----------|----|----------|
| VSCodeVim | `vscodevim.vim` | Core Neovim motions |
| Gruvbox Theme | `jdinhlife.gruvbox` | gruvbox.nvim |
| Todo Tree | `gruntfuggly.todo-tree` | todo-comments.nvim |
| GitLens | `eamodio.gitlens` | gitsigns.nvim |
| Error Lens | `usernamehw.errorlens` | diagnostics virtual_text |
| Go | `golang.go` | gopls config |
| rust-analyzer | `rust-lang.rust-analyzer` | rust-analyzer config |
| Markdown All in One | `yzhang.markdown-all-in-one` | markdown plugins |

## settings.json

### Editor Options (from options.lua)

- `editor.tabSize`: 2
- `editor.insertSpaces`: true
- `editor.lineNumbers`: "relative"
- `editor.cursorSurroundingLines`: 10 (scrolloff)
- `editor.wordWrap`: "on"
- `editor.wrappingIndent`: "indent" (breakindent)
- `editor.linkedEditing`: true
- `editor.formatOnSave`: true
- `editor.renderWhitespace`: "trailing"
- `editor.minimap.enabled`: false
- `editor.cursorBlinking`: "solid"

### Theme — Gruvbox Dark Hard + Pure Black Background

- `workbench.colorTheme`: "Gruvbox Dark Hard"
- `workbench.colorCustomizations`: Override editor, sidebar, activity bar, terminal, tab bar, title bar, status bar backgrounds to `#000000`

### VSCodeVim Config

- `vim.leader`: `<space>`
- `vim.easymotion`: true (replaces flash.nvim `s` jump)
- `vim.surround`: true (replaces mini.surround — note: uses `ys`/`ds`/`cs` keybindings, not mini.surround's `sa`/`sd`/`sr`)
- `vim.highlightedyank.enable`: true (replaces TextYankPost autocmd)
- `vim.hlsearch`: true
- `vim.ignorecase`: true
- `vim.smartcase`: true
- `vim.useSystemClipboard`: true (replaces `clipboard = 'unnamedplus'`)
- `vim.insertModeKeyBindings`: `jk` → `<Esc>`

### VSCodeVim normalModeKeyBindingsNonRecursive

**Save/quit:**
- `<leader>w` → workbench.action.files.save
- `<leader>x` → workbench.action.files.save + workbench.action.closeActiveEditor

**Search (leader+s namespace):**
- `<leader>sf` → workbench.action.quickOpen (find files)
- `<leader>sg` → workbench.action.findInFiles (grep)
- `<leader>sw` → search word under cursor in files
- `<leader>sd` → workbench.actions.view.problems (diagnostics)
- `<leader>s.` → workbench.action.openRecent (recent files)
- `<leader>sk` → workbench.action.openGlobalKeybindings (search keymaps)
- `<leader>st` → todo-tree-view.focus (search TODOs via Todo Tree)
- `<leader><leader>` → workbench.action.showAllEditors (buffers)
- `<leader>/` → actions.find (find in current file)

**LSP (gr namespace):**
- `grd` → editor.action.revealDefinition
- `grD` → editor.action.revealDeclaration
- `grr` → editor.action.goToReferences
- `gri` → editor.action.goToImplementation
- `grt` → editor.action.goToTypeDefinition
- `grn` → editor.action.rename
- `gra` → editor.action.quickFix (code action)
- `gO` → workbench.action.gotoSymbol (document symbols)
- `gW` → workbench.action.showAllSymbols (workspace symbols)

**Diagnostics:**
- `[d` → editor.action.marker.prev
- `]d` → editor.action.marker.next
- `<leader>q` → workbench.actions.view.problems

**Git (via GitLens):**
- `[c` → workbench.action.editor.previousChange
- `]c` → workbench.action.editor.nextChange
- `<leader>tb` → gitlens.toggleLineBlame (toggle inline blame)

**Editing:**
- `J` → join lines keeping cursor position (via marks)
- `<C-d>` → half-page down + `zz` (center)
- `<C-u>` → half-page up + `zz` (center)
- `s` → EasyMotion jump (requires explicit binding: `"before": ["s"]` → `"after": ["leader", "leader", "s"]`)
- `-` → revealInExplorer (overrides Vim's line-up; same tradeoff as oil.nvim override in Neovim config)
- `<Esc>` → `:nohl` (clear search highlights)

**Toggles:**
- `<leader>th` → editor.action.toggleInlayHints (toggle inlay hints)
- `<leader>tb` → gitlens.toggleLineBlame (toggle git blame)

### VSCodeVim visualModeKeyBindingsNonRecursive

- `<` → indent left + reselect (`<gv`)
- `>` → indent right + reselect (`>gv`)

### Language-Specific Settings

**Go:**
- `go.formatTool`: "gofumpt"
- `go.lintTool`: "staticcheck"
- `go.lintOnSave`: "workspace"

**Rust:**
- `rust-analyzer.check.command`: "clippy"
- `rust-analyzer.cargo.allFeatures`: true

### GitLens

- Disable CodeLens (too noisy)
- Keep inline current line blame, subtle
- Keep gutter blame decorations

## keybindings.json

### Panel/Sidebar Navigation (Ctrl+h/j/Ctrl+Shift+j/l)

**Ctrl+h — Primary sidebar toggle/focus:**
- Sidebar hidden → open + focus
- Sidebar visible, not focused → focus
- Sidebar focused → close

**Ctrl+l — Secondary sidebar toggle/focus:**
- Same pattern as Ctrl+h but for secondary sidebar (Outline, Timeline)

**Ctrl+j — Navigate "down" toward terminal:**
- Editor focused, panel hidden → open + focus terminal
- Editor focused, panel visible → focus terminal
- Sidebar focused → focus terminal (open if needed)
- Terminal focused → maximize panel

**Ctrl+Shift+j — Navigate "up" toward editor (replaces Ctrl+k to avoid VSCode chord conflicts):**
- Terminal focused, panel maximized → unmaximize
- Terminal focused, panel normal → focus editor
- Sidebar focused → focus editor
- Editor focused → hide bottom panel

Note: All Ctrl+h/j/l bindings need `when` clauses to avoid conflicting with VSCodeVim insert mode. Ctrl+h in normal mode overrides Vim's cursor-left (use `h` instead).

### Other Keybindings

- `Alt+j` / `Alt+k` → move line down/up (VSCode built-in, already default)

## Reference Guide

A markdown document covering:

1. **File navigation** — Telescope → Quick Open, Explorer, Ctrl+Tab
2. **Search** — live_grep → Ctrl+Shift+F, grep_string → search word
3. **LSP** — gr* mappings, hover, peek, rename
4. **Git** — gitsigns → GitLens gutter, Source Control panel
5. **Editing** — surround (`ys`/`ds`/`cs` not `sa`/`sd`/`sr`), EasyMotion, line moves, indent
6. **Terminal** — Ctrl+j / Ctrl+Shift+j workflow
7. **Sidebars** — Ctrl+h/l workflow
8. **Things that work differently** — treesitter textobjects (gone), oil.nvim (Explorer), which-key (leader hints), surround keybinding change
9. **VSCode-native features worth learning** — multi-cursor (Ctrl+D, Ctrl+Shift+L), peek definition, breadcrumbs, Zen mode, Shift+Alt+Right expand selection (partial treesitter textobject replacement)

## Not Ported (No Equivalent or Not Applicable)

**Treesitter features:**
- Textobjects (`af`, `if`, `ac`, `ic`, `aa`, `ia`, `ai`, `ii`, `al`, `il`) — no VSCode equivalent; use Shift+Alt+Right/Left for expand/shrink selection as partial mitigation
- Incremental selection (`+`/`-`) — replaced by Shift+Alt+Right/Left
- Argument swap (`<leader>a`/`A`) — no equivalent
- Flash treesitter select (`S`) — no equivalent

**Search bindings (no direct equivalent):**
- `<leader>sh` (help tags) — not applicable in VSCode
- `<leader>ss` (telescope builtins) — not applicable
- `<leader>sr` (search resume) — no equivalent
- `<leader>s/` (search in open files) — can use Ctrl+Shift+F with "files to include" filter manually
- `<leader>sn` (search Neovim config) — not applicable post-transition

**Git hunk actions (use Source Control panel / GitLens gutter instead):**
- `<leader>hs` / `<leader>hS` (stage hunk/buffer) — use Source Control panel or GitLens inline gutter actions
- `<leader>hr` / `<leader>hR` (reset hunk/buffer) — use Source Control panel
- `<leader>hu` (undo stage hunk) — use Source Control panel
- `<leader>hp` (preview hunk) — GitLens shows inline; also hover gutter decorations
- `<leader>hb` (blame line) — replaced by `<leader>tb` toggle
- `<leader>hd` / `<leader>hD` (diff against index/commit) — use GitLens diff commands via command palette
- `<leader>tD` (toggle deleted lines) — no GitLens equivalent

**Window/navigation:**
- `<leader>z` (window zoom) — no clean equivalent; use Zen mode (Ctrl+K Z) for distraction-free
- `<leader>;` (toggle last window) — use Ctrl+Tab for recent editor
- `<leader>-` (open cwd in Oil) — use Explorer sidebar
- `<leader>gg` (LazyGit) — replaced by Source Control panel

**Other:**
- Session persistence — VSCode handles natively
- Oil.nvim filesystem-as-buffer editing — use Explorer sidebar
- `<Esc><Esc>` terminal escape — VSCode terminal uses Ctrl+Shift+` to toggle; Ctrl+Shift+j to focus editor
