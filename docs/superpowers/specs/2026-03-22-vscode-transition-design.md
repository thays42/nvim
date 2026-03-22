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
| Error Lens | `usernameheo.errorlens` | diagnostics virtual_text |
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
- `vim.surround`: true (replaces mini.surround)
- `vim.highlightedyank.enable`: true (replaces TextYankPost autocmd)
- `vim.hlsearch`: true
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
- `<leader><leader>` → workbench.action.showAllEditors (buffers)
- `<leader>/` → actions.find (find in current file)

**LSP (gr namespace):**
- `grd` → editor.action.revealDefinition
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

**Editing:**
- `J` → join lines keeping cursor position (via marks)
- `<C-d>` → half-page down + `zz` (center)
- `<C-u>` → half-page up + `zz` (center)
- `s` → EasyMotion jump (flash equivalent)
- `-` → workbench.action.toggleSidebarVisibility + explorer focus

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

### Panel/Sidebar Navigation (Ctrl+h/j/k/l)

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

**Ctrl+k — Navigate "up" toward editor:**
- Terminal focused, panel maximized → unmaximize
- Terminal focused, panel normal → focus editor
- Sidebar focused → focus editor
- Editor focused → hide bottom panel

### Other Keybindings

- `Alt+j` / `Alt+k` → move line down/up (VSCode built-in, already default)

## Reference Guide

A markdown document covering:

1. **File navigation** — Telescope → Quick Open, Explorer, Ctrl+Tab
2. **Search** — live_grep → Ctrl+Shift+F, grep_string → search word
3. **LSP** — gr* mappings, hover, peek, rename
4. **Git** — gitsigns → GitLens gutter, Source Control panel
5. **Editing** — surround, EasyMotion, line moves, indent
6. **Terminal** — Ctrl+j/k workflow
7. **Sidebars** — Ctrl+h/l workflow
8. **Things that work differently** — treesitter textobjects (gone), oil.nvim (Explorer), which-key (leader hints)
9. **VSCode-native features worth learning** — multi-cursor (Ctrl+D, Ctrl+Shift+L), peek definition, breadcrumbs, Zen mode

## Not Ported (No Equivalent)

- Treesitter textobjects (`af`, `if`, `ac`, `ic`, etc.)
- Incremental selection (`+`/`-`)
- Argument swap (`<leader>a`/`A`)
- Oil.nvim filesystem-as-buffer editing
- Flash treesitter select (`S`)
- Session persistence (VSCode handles this natively)
- Window zoom (`<leader>z`)
