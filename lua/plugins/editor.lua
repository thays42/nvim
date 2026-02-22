return {
  -- Treesitter for syntax highlighting and code understanding
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- Use master branch for stable API
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'go',
          'gomod',
          'gosum',
          'lua',
          'luadoc',
          'vim',
          'vimdoc',
          'markdown',
          'markdown_inline',
          'json',
          'yaml',
          'r',
          'rnoweb',
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn', -- Start selection with gnn (go node)
            node_incremental = '+', -- Expand selection
            scope_incremental = false,
            node_decremental = '-', -- Shrink selection
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = { query = '@function.outer', desc = 'around function' },
              ['if'] = { query = '@function.inner', desc = 'inside function' },
              ['ac'] = { query = '@class.outer', desc = 'around class' },
              ['ic'] = { query = '@class.inner', desc = 'inside class' },
              ['aa'] = { query = '@parameter.outer', desc = 'around argument' },
              ['ia'] = { query = '@parameter.inner', desc = 'inside argument' },
              ['ai'] = { query = '@conditional.outer', desc = 'around if' },
              ['ii'] = { query = '@conditional.inner', desc = 'inside if' },
              ['al'] = { query = '@loop.outer', desc = 'around loop' },
              ['il'] = { query = '@loop.inner', desc = 'inside loop' },
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              [']f'] = { query = '@function.outer', desc = 'Next function start' },
              [']c'] = { query = '@class.outer', desc = 'Next class start' },
              [']a'] = { query = '@parameter.inner', desc = 'Next argument' },
            },
            goto_next_end = {
              [']F'] = { query = '@function.outer', desc = 'Next function end' },
              [']C'] = { query = '@class.outer', desc = 'Next class end' },
            },
            goto_previous_start = {
              ['[f'] = { query = '@function.outer', desc = 'Previous function start' },
              ['[c'] = { query = '@class.outer', desc = 'Previous class start' },
              ['[a'] = { query = '@parameter.inner', desc = 'Previous argument' },
            },
            goto_previous_end = {
              ['[F'] = { query = '@function.outer', desc = 'Previous function end' },
              ['[C'] = { query = '@class.outer', desc = 'Previous class end' },
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = { query = '@parameter.inner', desc = 'Swap with next argument' },
            },
            swap_previous = {
              ['<leader>A'] = { query = '@parameter.inner', desc = 'Swap with previous argument' },
            },
          },
        },
      }
    end,
  },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- Surround text objects
  {
    'echasnovski/mini.surround',
    version = '*',
    opts = {},
  },

  -- Better text objects
  {
    'echasnovski/mini.ai',
    version = '*',
    opts = { n_lines = 500 },
  },

  -- Detect tabstop and shiftwidth automatically
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- Undo tree visualization
  {
    'mbbill/undotree',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<CR>', desc = '[U]ndo tree' },
    },
  },

  -- Highlight TODO, FIXME, etc
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next [T]odo comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous [T]odo comment',
      },
      { '<leader>st', '<cmd>TodoTelescope<CR>', desc = '[S]earch [T]odos' },
    },
  },

  -- Which-key for keybinding hints
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 300,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>l', group = '[L]SP' },
        { '<leader>p', group = '[P]ersistence' },
      },
    },
  },
}
