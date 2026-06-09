return {
  -- Treesitter for syntax highlighting and code understanding.
  -- NOTE: migrated to the `main` branch. The `master` branch is frozen and does
  -- not support Neovim 0.12+ (it caused `node:range (a nil value)` crashes). On
  -- `main`, highlight/indent/incremental_selection are no longer modules:
  -- highlighting + indent are enabled per-buffer below, and incremental
  -- selection is provided by flash.nvim.
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    config = function()
      -- Install parsers. `main` has no `ensure_installed`/`auto_install`.
      require('nvim-treesitter').install {
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
        'rust', -- added: was auto-installed on master
        'toml', -- added: Cargo.toml / crates.nvim
      }

      -- Enable highlighting + (experimental) indentation per buffer.
      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Start treesitter highlighting/indent when a parser is available',
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Incremental selection (replaces the removed module) via flash.nvim.
      vim.keymap.set({ 'n', 'x', 'o' }, 'gnn', function()
        require('flash').treesitter()
      end, { desc = 'Treesitter selection (flash)' })

      -- Textobjects: on `main`, setup() only sets options; keymaps are manual.
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- select (visual / operator-pending)
      for lhs, q in pairs {
        ['af'] = { '@function.outer', 'around function' },
        ['if'] = { '@function.inner', 'inside function' },
        ['ac'] = { '@class.outer', 'around class' },
        ['ic'] = { '@class.inner', 'inside class' },
        ['aa'] = { '@parameter.outer', 'around argument' },
        ['ia'] = { '@parameter.inner', 'inside argument' },
        ['ai'] = { '@conditional.outer', 'around if' },
        ['ii'] = { '@conditional.inner', 'inside if' },
        ['al'] = { '@loop.outer', 'around loop' },
        ['il'] = { '@loop.inner', 'inside loop' },
      } do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(q[1], 'textobjects')
        end, { desc = q[2] })
      end

      -- move (goto next/previous start/end)
      for _, m in ipairs {
        { ']f', 'goto_next_start', '@function.outer', 'Next function start' },
        { ']c', 'goto_next_start', '@class.outer', 'Next class start' },
        { ']a', 'goto_next_start', '@parameter.inner', 'Next argument' },
        { ']F', 'goto_next_end', '@function.outer', 'Next function end' },
        { ']C', 'goto_next_end', '@class.outer', 'Next class end' },
        { '[f', 'goto_previous_start', '@function.outer', 'Previous function start' },
        { '[c', 'goto_previous_start', '@class.outer', 'Previous class start' },
        { '[a', 'goto_previous_start', '@parameter.inner', 'Previous argument' },
        { '[F', 'goto_previous_end', '@function.outer', 'Previous function end' },
        { '[C', 'goto_previous_end', '@class.outer', 'Previous class end' },
      } do
        vim.keymap.set({ 'n', 'x', 'o' }, m[1], function()
          move[m[2]](m[3], 'textobjects')
        end, { desc = m[4] })
      end

      -- swap
      vim.keymap.set('n', '<leader>a', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap with next argument' })
      vim.keymap.set('n', '<leader>A', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap with previous argument' })
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
        { '<leader>r', group = '[R]eview' },
      },
    },
  },
}
