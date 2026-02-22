return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'crispgm/telescope-heading.nvim' },
  },
  config = function()
    require('telescope').setup {
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'r_help')
    pcall(require('telescope').load_extension, 'heading')

    local builtin = require 'telescope.builtin'
    local map = vim.keymap.set

    -- File navigation
    map('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    map('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    map('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    map('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })
    map('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- Help and introspection
    map('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    map('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    map('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    map('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    map('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })

    -- Buffer search
    map('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    map('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Neovim config search
    map('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- R documentation search
    map('n', '<leader>sR', function()
      require('telescope').extensions.r_help.r_help()
    end, { desc = '[S]earch [R] documentation' })

    -- Markdown heading search (outline-style, document order)
    map('n', '<leader>sm', function()
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions = require 'telescope.actions'
      local actions_state = require 'telescope.actions.state'
      local conf = require('telescope.config').values

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local headings = {}
      local in_code_block = false
      for i, line in ipairs(lines) do
        if line:match '^```' then
          in_code_block = not in_code_block
        elseif not in_code_block and line:match '^#+ ' then
          table.insert(headings, { heading = vim.trim(line), lnum = i })
        end
      end

      pickers
        .new({ sorting_strategy = 'ascending' }, {
          prompt_title = 'Headings',
          results_title = 'Headings',
          finder = finders.new_table {
            results = headings,
            entry_maker = function(entry)
              return {
                value = entry.lnum,
                display = entry.heading,
                ordinal = string.format('%05d %s', entry.lnum, entry.heading),
                lnum = entry.lnum,
                filename = vim.api.nvim_buf_get_name(0),
              }
            end,
          },
          sorter = sorters.get_generic_fuzzy_sorter(),
          previewer = conf.grep_previewer {},
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local entry = actions_state.get_selected_entry()
              actions.close(prompt_bufnr)
              vim.cmd(string.format('%d', entry.value))
            end)
            return true
          end,
        })
        :find()
    end, { desc = '[S]earch [M]arkdown headings' })

    -- Review thread search
    map('n', '<leader>sv', function()
      builtin.grep_string {
        search = '<!--REVIEW:open',
        glob_pattern = '*.md',
        prompt_title = 'Open Review Threads',
      }
    end, { desc = '[S]earch Re[V]iew threads' })
  end,
}
