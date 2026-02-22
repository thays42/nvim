return {
  -- Flash for fast navigation
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash jump',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash treesitter select',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote flash (operator)',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter search',
      },
      {
        '<C-s>',
        mode = 'c',
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle flash search',
      },
    },
  },

  -- Session persistence
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>ps',
        function()
          require('persistence').load()
        end,
        desc = '[P]ersistence: Load [S]ession (cwd)',
      },
      {
        '<leader>pS',
        function()
          require('persistence').select()
        end,
        desc = '[P]ersistence: [S]elect session',
      },
      {
        '<leader>pl',
        function()
          require('persistence').load { last = true }
        end,
        desc = '[P]ersistence: Load [L]ast session',
      },
      {
        '<leader>pd',
        function()
          require('persistence').stop()
        end,
        desc = "[P]ersistence: [D]on't save on exit",
      },
    },
  },
}
