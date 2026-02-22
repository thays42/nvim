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
          -- Markdown: tone down highlights for dark background
          ['@markup.raw'] = { fg = '#a89984', bg = 'NONE' }, -- Inline code: muted fg, no bg
          ['@markup.raw.block'] = { bg = 'NONE' }, -- Code block content: no bg (render-markdown handles it)
          ['@markup.raw.delimiter'] = { fg = '#504945' }, -- ``` fences: very dim
          ['@markup.heading.1'] = { fg = '#d79921', bold = true }, -- Muted yellow
          ['@markup.heading.2'] = { fg = '#98971a', bold = true }, -- Muted green
          ['@markup.heading.3'] = { fg = '#689d6a', bold = true }, -- Muted aqua
          ['@markup.heading.4'] = { fg = '#a89984', bold = true }, -- Gray
          ['@markup.heading.5'] = { fg = '#a89984' },
          ['@markup.heading.6'] = { fg = '#7c6f64' },
          ['@markup.link'] = { fg = '#689d6a' }, -- Muted aqua for links
          ['@markup.link.url'] = { fg = '#504945', underline = true }, -- Very dim URLs
          ['@markup.list'] = { fg = '#7c6f64' }, -- Dim list markers
          ['@markup.italic'] = { fg = '#bdae93', italic = true },
          ['@markup.strong'] = { fg = '#d5c4a1', bold = true },
          ['@markup.quote'] = { fg = '#7c6f64', italic = true }, -- Dim blockquotes
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
