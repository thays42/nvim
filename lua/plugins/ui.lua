return {
  -- Colorscheme
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup {
        contrast = 'hard',
        italic = {
          strings = false,
          comments = false,
          operators = false,
        },
        overrides = {
          ['@comment.documentation'] = { fg = '#a89984' }, -- Lighter gray for roxygen
          -- Pure black background (vitesse-style)
          Normal = { bg = '#000000' },
          NormalFloat = { bg = '#000000' },
          SignColumn = { bg = '#000000' },
          LineNr = { bg = '#000000' },
          CursorLineNr = { bg = '#000000' },
          FoldColumn = { bg = '#000000' },
        },
      }
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  -- File explorer (edit filesystem like a buffer)
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    keys = {
      { '-', '<cmd>Oil<CR>', desc = 'Open parent directory' },
      {
        '<leader>-',
        function()
          require('oil').open(vim.fn.getcwd())
        end,
        desc = 'Open cwd in Oil',
      },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['q'] = 'actions.close',
        ['<C-s>'] = false, -- disable default, conflicts with flash
        ['<C-v>'] = 'actions.select_vsplit',
        ['<C-x>'] = 'actions.select_split',
      },
    },
  },

  -- Statusline
  {
    'echasnovski/mini.statusline',
    version = '*',
    config = function()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Icons
  { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
}
