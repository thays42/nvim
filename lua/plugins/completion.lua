return {
  -- Autocompletion
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        opts = {},
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load { paths = { '.vscode' } }
        end,
      },
      'folke/lazydev.nvim',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 0 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
    config = function(_, opts)
      require('blink.cmp').setup(opts)

      -- Patch documentation popup to align with selected item instead of menu top
      local ok_docs, docs = pcall(require, 'blink.cmp.completion.windows.documentation')
      local ok_menu, menu = pcall(require, 'blink.cmp.completion.windows.menu')
      if not ok_docs or not ok_menu then
        return
      end

      local orig_update = docs.update_position
      docs.update_position = function()
        orig_update()
        if not docs.win:is_open() or not menu.win:is_open() then
          return
        end
        if not menu.selected_item_idx then
          return
        end

        local doc_winnr = docs.win:get_win()
        local menu_winnr = menu.win:get_win()
        if not doc_winnr or not menu_winnr then
          return
        end

        local top_line = vim.fn.line('w0', menu_winnr)
        local visual_row = menu.selected_item_idx - top_line

        local cfg = vim.api.nvim_win_get_config(doc_winnr)
        cfg.row = cfg.row + visual_row
        vim.api.nvim_win_set_config(doc_winnr, cfg)
      end
    end,
  },

  -- Lazydev for Neovim Lua API completion
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = '${3rd}/love2d/library', words = { 'love' } },
      },
    },
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'gofmt', 'goimports' },
        r = { 'air' },
      },
      formatters = {
        air = {
          command = 'air',
          args = { 'format', '$FILENAME' },
          stdin = false,
        },
      },
    },
  },
}
