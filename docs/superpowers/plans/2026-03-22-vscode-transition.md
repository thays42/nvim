# VSCode Transition Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a version-controlled VSCode config (settings.json, keybindings.json, reference guide) that recreates the Neovim experience for Markdown, Go, and Rust workflows using VSCodeVim.

**Architecture:** Three files in `~/projects/vscode/` — `settings.json` for editor/vim/theme/language config, `keybindings.json` for panel navigation (Ctrl+h/j/l, Ctrl+Shift+j), and `reference-guide.md` mapping Neovim workflows to VSCode equivalents. After creation, symlink settings.json and keybindings.json into `~/.config/Code/User/`.

**Tech Stack:** VSCode, VSCodeVim extension, JSON config files

**Spec:** `docs/superpowers/specs/2026-03-22-vscode-transition-design.md`

---

## File Structure

```
~/projects/vscode/
├── settings.json        # Editor options, VSCodeVim config, theme, language settings
├── keybindings.json     # Panel/sidebar navigation keybindings with when clauses
└── reference-guide.md   # Neovim → VSCode workflow mapping document
```

After creation, symlinks:
- `~/projects/vscode/settings.json` → `~/.config/Code/User/settings.json`
- `~/projects/vscode/keybindings.json` → `~/.config/Code/User/keybindings.json`

---

## Prerequisite

The repo at `~/projects/vscode/` has already been created and `git init` has been run.

---

## Chunk 1: settings.json

### Task 1: Create settings.json with editor options and theme

**Files:**
- Create: `~/projects/vscode/settings.json`

- [ ] **Step 1: Write settings.json**

The file merges the user's existing VSCodeVim settings with new options from the spec. Preserve existing settings: `chat.agent.enabled`, `telemetry.*`, `vim.handleKeys`, `extensions.experimental.affinity`, and the `K` → lineBreakInsert binding and `v`/`V` smart select bindings.

```json
{
  // === Editor Options (from Neovim options.lua) ===
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.lineNumbers": "relative",
  "editor.cursorSurroundingLines": 10,
  "editor.wordWrap": "on",
  "editor.wrappingIndent": "indent",
  "editor.linkedEditing": true,
  "editor.formatOnSave": true,
  "editor.renderWhitespace": "trailing",
  "editor.minimap.enabled": false,
  "editor.cursorBlinking": "solid",

  // === Theme — Gruvbox Dark Hard + Pure Black Background ===
  "workbench.colorTheme": "Gruvbox Dark Hard",
  "workbench.colorCustomizations": {
    "[Gruvbox Dark Hard]": {
      "editor.background": "#000000",
      "editorWidget.background": "#000000",
      "sideBar.background": "#000000",
      "sideBarSectionHeader.background": "#000000",
      "activityBar.background": "#000000",
      "terminal.background": "#000000",
      "tab.activeBackground": "#000000",
      "tab.inactiveBackground": "#000000",
      "editorGroupHeader.tabsBackground": "#000000",
      "titleBar.activeBackground": "#000000",
      "titleBar.inactiveBackground": "#000000",
      "statusBar.background": "#000000",
      "statusBar.noFolderBackground": "#000000",
      "panel.background": "#000000",
      "breadcrumb.background": "#000000",
      "list.activeSelectionBackground": "#3c3836",
      "list.hoverBackground": "#1d2021",
      "list.inactiveSelectionBackground": "#1d2021"
    }
  },

  // === VSCodeVim Config ===
  "vim.leader": "<space>",
  "vim.easymotion": true,
  "vim.surround": true,
  "vim.highlightedyank.enable": true,
  "vim.highlightedyank.duration": 200,
  "vim.hlsearch": true,
  "vim.incsearch": true,
  "vim.ignorecase": true,
  "vim.smartcase": true,
  "vim.useSystemClipboard": true,
  "vim.useCtrlKeys": true,
  "vim.handleKeys": {
    "<C-a>": false,
    "<C-f>": false
  },

  // === Insert Mode ===
  "vim.insertModeKeyBindings": [
    {
      "before": ["j", "k"],
      "after": ["<Esc>"]
    }
  ],

  // === Normal Mode ===
  "vim.normalModeKeyBindingsNonRecursive": [
    // -- Save/quit --
    {
      "before": ["<leader>", "w"],
      "commands": ["workbench.action.files.save"]
    },
    {
      "before": ["<leader>", "x"],
      "commands": ["workbench.action.files.save", "workbench.action.closeActiveEditor"]
    },

    // -- Search (leader+s namespace) --
    {
      "before": ["<leader>", "s", "f"],
      "commands": ["workbench.action.quickOpen"]
    },
    {
      "before": ["<leader>", "s", "g"],
      "commands": ["workbench.action.findInFiles"]
    },
    {
      "before": ["<leader>", "s", "w"],
      "commands": ["workbench.action.findInFiles"],
      "args": { "query": "${selectedText}" }
    },
    {
      "before": ["<leader>", "s", "d"],
      "commands": ["workbench.actions.view.problems"]
    },
    {
      "before": ["<leader>", "s", "."],
      "commands": ["workbench.action.openRecent"]
    },
    {
      "before": ["<leader>", "s", "k"],
      "commands": ["workbench.action.openGlobalKeybindings"]
    },
    {
      "before": ["<leader>", "s", "t"],
      "commands": ["todo-tree-view.focus"]
    },
    {
      "before": ["<leader>", "<leader>"],
      "commands": ["workbench.action.showAllEditors"]
    },
    {
      "before": ["<leader>", "/"],
      "commands": ["actions.find"]
    },

    // -- LSP (gr namespace) --
    {
      "before": ["g", "r", "d"],
      "commands": ["editor.action.revealDefinition"]
    },
    {
      "before": ["g", "r", "D"],
      "commands": ["editor.action.revealDeclaration"]
    },
    {
      "before": ["g", "r", "r"],
      "commands": ["editor.action.goToReferences"]
    },
    {
      "before": ["g", "r", "i"],
      "commands": ["editor.action.goToImplementation"]
    },
    {
      "before": ["g", "r", "t"],
      "commands": ["editor.action.goToTypeDefinition"]
    },
    {
      "before": ["g", "r", "n"],
      "commands": ["editor.action.rename"]
    },
    {
      "before": ["g", "r", "a"],
      "commands": ["editor.action.quickFix"]
    },
    {
      "before": ["g", "O"],
      "commands": ["workbench.action.gotoSymbol"]
    },
    {
      "before": ["g", "W"],
      "commands": ["workbench.action.showAllSymbols"]
    },

    // -- Diagnostics --
    {
      "before": ["[", "d"],
      "commands": ["editor.action.marker.prev"]
    },
    {
      "before": ["]", "d"],
      "commands": ["editor.action.marker.next"]
    },
    {
      "before": ["<leader>", "q"],
      "commands": ["workbench.actions.view.problems"]
    },

    // -- Git (GitLens) --
    {
      "before": ["[", "c"],
      "commands": ["workbench.action.editor.previousChange"]
    },
    {
      "before": ["]", "c"],
      "commands": ["workbench.action.editor.nextChange"]
    },

    // -- Toggles --
    {
      "before": ["<leader>", "t", "h"],
      "commands": ["editor.action.toggleInlayHints"]
    },
    {
      "before": ["<leader>", "t", "b"],
      "commands": ["gitlens.toggleLineBlame"]
    },

    // -- Editing --
    {
      "before": ["J"],
      "after": ["m", "z", "J", "`", "z"]
    },
    {
      "before": ["<C-d>"],
      "after": ["<C-d>", "z", "z"]
    },
    {
      "before": ["<C-u>"],
      "after": ["<C-u>", "z", "z"]
    },
    {
      "before": ["s"],
      "after": ["<leader>", "<leader>", "s"]
    },
    {
      "before": ["-"],
      "commands": ["workbench.files.action.focusFilesExplorer"]
    },
    {
      "before": ["<Esc>"],
      "commands": [":nohl"],
      "silent": true
    },

    // -- Existing user bindings --
    {
      "before": ["K"],
      "commands": ["lineBreakInsert"],
      "silent": true
    }
  ],

  // === Visual Mode ===
  "vim.visualModeKeyBindingsNonRecursive": [
    {
      "before": ["<"],
      "after": ["<", "g", "v"]
    },
    {
      "before": [">"],
      "after": [">", "g", "v"]
    }
  ],

  // === Existing visual mode bindings ===
  "vim.visualModeKeyBindings": [
    {
      "before": ["v"],
      "commands": ["editor.action.smartSelect.expand"]
    },
    {
      "before": ["V"],
      "commands": ["editor.action.smartSelect.shrink"]
    }
  ],

  // === Language: Go ===
  "go.formatTool": "gofumpt",
  "go.lintTool": "staticcheck",
  "go.lintOnSave": "workspace",

  // === Language: Rust ===
  "rust-analyzer.check.command": "clippy",
  "rust-analyzer.cargo.allFeatures": true,

  // === GitLens (subtle, not noisy) ===
  "gitlens.codeLens.enabled": false,
  "gitlens.currentLine.enabled": true,
  "gitlens.currentLine.delay": 500,
  "gitlens.hovers.currentLine.over": "line",

  // === Error Lens ===
  "errorLens.delay": 500,

  // === Telemetry / Misc (existing user preferences) ===
  "chat.agent.enabled": false,
  "telemetry.feedback.enabled": false,
  "telemetry.telemetryLevel": "off",

  // === Performance ===
  "extensions.experimental.affinity": {
    "vscodevim.vim": 1
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd ~/projects/vscode
git add settings.json
git commit -m "feat: add settings.json with editor, vim, theme, and language config"
```

---

## Chunk 2: keybindings.json

### Task 2: Create keybindings.json with panel/sidebar navigation

**Files:**
- Create: `~/projects/vscode/keybindings.json`

- [ ] **Step 1: Write keybindings.json**

Implements the Ctrl+h/j/l and Ctrl+Shift+j navigation state machine. Each binding has a `when` clause to fire only in the correct context. Note: these are VSCode-level keybindings (not VSCodeVim), so they use `when` clauses to avoid conflicts with Vim insert mode.

```json
[
  // =============================================
  // Ctrl+h — Primary sidebar toggle/focus
  // All entries exclude Vim insert mode to preserve Ctrl+h = backspace
  // =============================================

  // Sidebar not focused → open + focus (focusSideBar opens it if hidden)
  {
    "key": "ctrl+h",
    "command": "workbench.action.focusSideBar",
    "when": "!sideBarFocus && vim.mode != 'Insert'"
  },
  // Sidebar focused → close it
  {
    "key": "ctrl+h",
    "command": "workbench.action.toggleSidebarVisibility",
    "when": "sideBarFocus && vim.mode != 'Insert'"
  },

  // =============================================
  // Ctrl+l — Secondary sidebar toggle/focus
  // All entries exclude Vim insert mode
  // =============================================

  // Secondary sidebar not focused → open + focus
  {
    "key": "ctrl+l",
    "command": "workbench.action.focusAuxiliaryBar",
    "when": "!auxiliaryBarFocus && vim.mode != 'Insert'"
  },
  // Secondary sidebar focused → close it
  {
    "key": "ctrl+l",
    "command": "workbench.action.toggleAuxiliaryBar",
    "when": "auxiliaryBarFocus && vim.mode != 'Insert'"
  },

  // =============================================
  // Ctrl+j — Navigate "down" toward terminal
  // All entries exclude Vim insert mode to preserve Ctrl+j = newline
  // =============================================

  // Editor or sidebar focused → focus terminal (opens panel if hidden)
  {
    "key": "ctrl+j",
    "command": "workbench.action.terminal.focus",
    "when": "(editorFocus || sideBarFocus || auxiliaryBarFocus) && vim.mode != 'Insert'"
  },
  // Terminal focused → maximize panel
  {
    "key": "ctrl+j",
    "command": "workbench.action.toggleMaximizedPanel",
    "when": "terminalFocus"
  },

  // =============================================
  // Ctrl+Shift+j — Navigate "up" toward editor
  // =============================================

  // Terminal focused, panel maximized → unmaximize
  // Note: use Developer: Inspect Context Keys to verify the correct
  // context key name for your VSCode version (may be "panelMaximized"
  // or "panel.isMaximized" depending on version)
  {
    "key": "ctrl+shift+j",
    "command": "workbench.action.toggleMaximizedPanel",
    "when": "terminalFocus && panelMaximized"
  },
  // Terminal focused, panel normal → focus editor
  {
    "key": "ctrl+shift+j",
    "command": "workbench.action.focusActiveEditorGroup",
    "when": "terminalFocus && !panelMaximized"
  },
  // Sidebar focused → focus editor
  {
    "key": "ctrl+shift+j",
    "command": "workbench.action.focusActiveEditorGroup",
    "when": "sideBarFocus || auxiliaryBarFocus"
  },
  // Editor focused → hide bottom panel
  {
    "key": "ctrl+shift+j",
    "command": "workbench.action.togglePanel",
    "when": "editorFocus && panelVisible"
  },

  // =============================================
  // Disable defaults that conflict
  // =============================================

  // Ctrl+h: disable default "find and replace" in editor
  // (use Ctrl+Shift+H or command palette for find-and-replace)
  {
    "key": "ctrl+h",
    "command": "-editor.action.startFindReplaceAction"
  },
  // Ctrl+l: disable default "select line" / "expandLineSelection"
  {
    "key": "ctrl+l",
    "command": "-expandLineSelection"
  },
  // Ctrl+j: disable default "toggle panel"
  {
    "key": "ctrl+j",
    "command": "-workbench.action.togglePanel"
  }
]
```

- [ ] **Step 2: Commit**

```bash
cd ~/projects/vscode
git add keybindings.json
git commit -m "feat: add keybindings.json with panel/sidebar navigation"
```

---

## Chunk 3: Reference guide

### Task 3: Create reference-guide.md

**Files:**
- Create: `~/projects/vscode/reference-guide.md`

- [ ] **Step 1: Write reference-guide.md**

```markdown
# Neovim → VSCode Reference Guide

Quick reference for translating Neovim muscle memory to VSCode + VSCodeVim.

## Basics

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `jk` (insert mode) | `jk` | Exit insert mode |
| `<leader>w` | `<leader>w` | Save file |
| `<leader>x` | `<leader>x` | Save and close file |
| `<Esc>` | `<Esc>` | Clear search highlights |

## File Navigation

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `<leader>sf` (Telescope find_files) | `<leader>sf` or `Ctrl+P` | Quick Open |
| `<leader>sg` (Telescope live_grep) | `<leader>sg` or `Ctrl+Shift+F` | Search across files |
| `<leader>sw` (grep word under cursor) | `<leader>sw` | Search word under cursor in files |
| `<leader>s.` (recent files) | `<leader>s.` | Open Recent |
| `<leader><leader>` (buffers) | `<leader><leader>` | Show All Editors |
| `<leader>/` (buffer fuzzy find) | `<leader>/` or `Ctrl+F` | Find in current file |
| `-` (oil.nvim parent dir) | `-` | Focus file explorer |

## LSP

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `grd` | `grd` | Go to definition |
| `grD` | `grD` | Go to declaration |
| `grr` | `grr` | Go to references |
| `gri` | `gri` | Go to implementation |
| `grt` | `grt` | Go to type definition |
| `grn` | `grn` | Rename symbol |
| `gra` | `gra` | Code action / quick fix |
| `gO` | `gO` | Document symbols (outline) |
| `gW` | `gW` | Workspace symbols |
| `K` (hover) | `gh` (VSCodeVim default) | `K` is remapped to line break insert; use `gh` for hover |

## Diagnostics

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `[d` / `]d` | `[d` / `]d` | Previous/next diagnostic |
| `<leader>q` | `<leader>q` | Open Problems panel |
| `<leader>sd` | `<leader>sd` | Same as `<leader>q` |

## Git

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `[c` / `]c` | `[c` / `]c` | Previous/next git change |
| `<leader>tb` | `<leader>tb` | Toggle inline blame (GitLens) |
| `<leader>hs` (stage hunk) | Source Control panel | Click `+` on changed file or hunk |
| `<leader>hr` (reset hunk) | Source Control panel | Click ↩ on changed file |
| `<leader>hb` (blame line) | `<leader>tb` | Toggle persistent blame |
| `<leader>hd` (diff index) | GitLens: Open Changes | Via command palette |
| `<leader>gg` (LazyGit) | `Ctrl+Shift+G` | Source Control panel |

## Editing

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `s` (flash.nvim jump) | `s` (EasyMotion) | Type `s` then 2 chars to jump |
| `ys`/`ds`/`cs` (surround) | Same | **Changed from Neovim's** `sa`/`sd`/`sr` (mini.surround) |
| `J` | `J` | Join lines, cursor stays put |
| `<C-d>` / `<C-u>` | `<C-d>` / `<C-u>` | Half-page scroll, centered |
| `<` / `>` (visual) | `<` / `>` | Indent, stays in visual mode |
| `Alt+j` / `Alt+k` | `Alt+j` / `Alt+k` | Move line up/down (VSCode built-in) |
| `v` / `V` (visual) | `v` / `V` | Expand/shrink smart selection |

## Toggles

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `<leader>th` | `<leader>th` | Toggle inlay hints |
| `<leader>tb` | `<leader>tb` | Toggle line blame |

## Search Extras

| Neovim | VSCode | Notes |
|--------|--------|-------|
| `<leader>sk` | `<leader>sk` | Open keyboard shortcuts |
| `<leader>st` | `<leader>st` | Focus Todo Tree panel |

## Panel Navigation

This is the custom Ctrl+h/j/l/Shift+j navigation system:

### Terminal (Ctrl+j / Ctrl+Shift+j)

| From | Key | Action |
|------|-----|--------|
| Editor (panel hidden) | `Ctrl+j` | Open + focus terminal |
| Editor (panel visible) | `Ctrl+j` | Focus terminal |
| Terminal | `Ctrl+j` | Maximize terminal panel |
| Terminal (maximized) | `Ctrl+Shift+j` | Unmaximize |
| Terminal (normal) | `Ctrl+Shift+j` | Focus editor |
| Editor | `Ctrl+Shift+j` | Hide bottom panel |

### Sidebars (Ctrl+h / Ctrl+l)

| From | Key | Action |
|------|-----|--------|
| Anywhere (sidebar hidden) | `Ctrl+h` | Open + focus primary sidebar |
| Anywhere (sidebar visible) | `Ctrl+h` | Focus primary sidebar |
| Primary sidebar | `Ctrl+h` | Close primary sidebar |
| Anywhere (secondary hidden) | `Ctrl+l` | Open + focus secondary sidebar |
| Anywhere (secondary visible) | `Ctrl+l` | Focus secondary sidebar |
| Secondary sidebar | `Ctrl+l` | Close secondary sidebar |

### Cross-panel

| From | Key | Action |
|------|-----|--------|
| Any sidebar | `Ctrl+j` | Focus terminal |
| Any sidebar | `Ctrl+Shift+j` | Focus editor |

## Things That Work Differently

### No treesitter textobjects
Neovim's `af` (around function), `if` (inside function), `ac` (around class), etc. have no VSCode equivalent. **Partial mitigation:** Use `Shift+Alt+Right` to expand selection and `Shift+Alt+Left` to shrink — similar to the `+`/`-` incremental selection, though less precise.

### Surround keybindings changed
- **Neovim (mini.surround):** `sa` (add), `sd` (delete), `sr` (replace)
- **VSCode (vim-surround):** `ys` (add), `ds` (delete), `cs` (replace)

Example: To surround a word with quotes:
- Neovim: `saiw"`
- VSCode: `ysiw"`

### File explorer is different
Oil.nvim lets you edit the filesystem like a buffer. VSCode's Explorer sidebar is a traditional tree view. `-` focuses it, but you navigate with arrow keys or `j`/`k`, not Vim buffer commands.

### No which-key popup
VSCodeVim shows a brief hint after pressing `<leader>` if you wait, but it's not as rich as which-key.nvim. Use `<leader>sk` to open keyboard shortcuts search if you forget a binding.

### Find and replace
- Neovim: `:%s/old/new/g`
- VSCode: Still works in VSCodeVim command mode!
- In-file replace: Use command palette → "Find and Replace" (since `Ctrl+h` is remapped to sidebar)
- Across files: `Ctrl+Shift+H` works as normal

## VSCode-Native Features Worth Learning

These don't exist in your Neovim config but are powerful in VSCode:

| Feature | Shortcut | What it does |
|---------|----------|-------------|
| **Multi-cursor** | `Ctrl+D` | Select next occurrence of current word |
| **Select all occurrences** | `Ctrl+Shift+L` | Multi-cursor on all occurrences |
| **Peek definition** | `Alt+F12` | Inline definition preview without leaving current file |
| **Breadcrumbs** | `Ctrl+Shift+.` | Navigate file structure from breadcrumb bar |
| **Zen mode** | `Ctrl+K Z` | Distraction-free fullscreen (like `<leader>z` zoom) |
| **Column select** | `Shift+Alt+drag` or `Ctrl+Shift+Alt+Arrow` | Rectangular selection |
| **Go to line** | `Ctrl+G` | Jump to line number |
| **Command palette** | `Ctrl+Shift+P` | Access any command by name |
| **Quick fix** | `Ctrl+.` | Same as `gra` but native shortcut |
| **Split editor** | `Ctrl+\` | Split current editor right |
```

- [ ] **Step 2: Commit**

```bash
cd ~/projects/vscode
git add reference-guide.md
git commit -m "feat: add Neovim to VSCode reference guide"
```

---

## Chunk 4: Symlinks and verification

### Task 4: Symlink config files and verify

- [ ] **Step 1: Back up existing VSCode settings and keybindings**

```bash
cp ~/.config/Code/User/settings.json ~/.config/Code/User/settings.json.bak
cp ~/.config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json.bak 2>/dev/null || true
```

- [ ] **Step 2: Create symlinks**

```bash
ln -sf ~/projects/vscode/settings.json ~/.config/Code/User/settings.json
ln -sf ~/projects/vscode/keybindings.json ~/.config/Code/User/keybindings.json
```

- [ ] **Step 3: Verify symlinks**

```bash
ls -la ~/.config/Code/User/settings.json ~/.config/Code/User/keybindings.json
```

Expected: both files show as symlinks pointing to `~/projects/vscode/`.

- [ ] **Step 4: Commit everything and verify repo state**

```bash
cd ~/projects/vscode
git log --oneline
```

Expected: 3 commits (settings.json, keybindings.json, reference-guide.md).

- [ ] **Step 5: Install missing extensions**

Run in terminal:
```bash
code --install-extension jdinhlife.gruvbox
code --install-extension gruntfuggly.todo-tree
code --install-extension eamodio.gitlens
code --install-extension usernamehw.errorlens
code --install-extension golang.go
code --install-extension rust-lang.rust-analyzer
code --install-extension yzhang.markdown-all-in-one
```

(VSCodeVim should already be installed since existing settings reference it.)

- [ ] **Step 6: Restart VSCode and verify**

Open VSCode and check:
1. Theme is Gruvbox Dark Hard with black background
2. Relative line numbers are showing
3. `jk` exits insert mode
4. `<space>sf` opens Quick Open
5. `Ctrl+j` opens/focuses terminal
6. `Ctrl+h` toggles sidebar
