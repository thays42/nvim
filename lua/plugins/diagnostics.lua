return {
  -- Trouble: a togglable panel for diagnostics, references, symbols, etc.
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {
      focus = true,
    },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Trouble: Diagnostics (workspace)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Trouble: Diagnostics (current buffer)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Trouble: Symbols',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'Trouble: LSP definitions / references',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Trouble: Location list',
      },
      {
        '<leader>xq',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Trouble: Quickfix list',
      },
    },
  },
}
