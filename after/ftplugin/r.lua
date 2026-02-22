-- Roxygen2 fine-grained highlighting (overlays on treesitter)
if vim.b.roxygen_highlights_loaded then
  return
end
vim.b.roxygen_highlights_loaded = true

-- Define highlight groups (Gruvbox colors)
vim.api.nvim_set_hl(0, 'RoxygenTag', { fg = '#8ec07c', bold = true }) -- Aqua
vim.api.nvim_set_hl(0, 'RoxygenParam', { fg = '#83a598' }) -- Blue

-- Match patterns (priority 10+ to render over treesitter)
vim.fn.matchadd('RoxygenTag', [[@\w\+]], 10)
vim.fn.matchadd('RoxygenParam', [[@param\s\+\zs\w\+]], 11)
