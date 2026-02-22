return {
  -- Database client
  {
    'tpope/vim-dadbod',
    cmd = { 'DB' },
  },

  -- Database UI
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' } },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    keys = {
      { '<leader>db', '<cmd>DBUIToggle<cr>', desc = 'Toggle [D]ata[B]ase UI' },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_env_variable_url = 'DATABASE_URL'
      vim.g.db_ui_env_variable_name = 'DATABASE_NAME'
      vim.g.db_ui_table_helpers = {
        postgresql = {
          ['Preview 5'] = 'SELECT * FROM "{table}" LIMIT 5',
          ['Count'] = 'SELECT COUNT(*) FROM "{table}"',
        },
        sqlite = {
          ['Preview 5'] = 'SELECT * FROM "{table}" LIMIT 5',
          ['Count'] = 'SELECT COUNT(*) FROM "{table}"',
        },
        mysql = {
          ['Preview 5'] = 'SELECT * FROM `{table}` LIMIT 5',
          ['Count'] = 'SELECT COUNT(*) FROM `{table}`',
        },
      }
    end,
  },
}
