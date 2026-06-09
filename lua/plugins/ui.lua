return {
  -- Colorscheme: Vitesse, forced to a pure-black background.
  {
    'ptdewey/vitesse-nvim',
    priority = 1000,
    config = function()
      -- Vitesse defaults to a #121212 background; force pure black instead.
      -- Driven by a ColorScheme autocmd so it survives any future :colorscheme
      -- (e.g. the <leader>sc picker) rather than being set once.
      local function force_black(group)
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg = '#000000'
        vim.api.nvim_set_hl(0, group, hl)
      end
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('PureBlackBg', { clear = true }),
        callback = function()
          for _, g in ipairs { 'Normal', 'NormalFloat', 'SignColumn', 'LineNr', 'CursorLineNr', 'FoldColumn' } do
            force_black(g)
          end
        end,
      })

      vim.cmd.colorscheme 'vitesse'
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
