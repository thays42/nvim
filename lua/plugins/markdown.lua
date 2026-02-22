return {
  -- Render markdown inline in Neovim
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', desc = '[T]oggle [M]arkdown rendering' },
    },
    opts = {
      code = {
        style = 'full',
        background = 'normal', -- Use highlight group below instead of default
        highlight = 'RenderMarkdownCode',
      },
      heading = {
        backgrounds = {
          'RenderMarkdownBg',
          'RenderMarkdownBg',
          'RenderMarkdownBg',
          'RenderMarkdownBg',
          'RenderMarkdownBg',
          'RenderMarkdownBg',
        },
      },
    },
    config = function(_, opts)
      -- Define dark highlight groups before setup
      vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = '#111111' })
      vim.api.nvim_set_hl(0, 'RenderMarkdownBg', { bg = '#0d0d0d' })
      require('render-markdown').setup(opts)
    end,
  },

  -- Follow markdown links (internal and external)
  {
    'jghauser/follow-md-links.nvim',
    ft = { 'markdown' },
  },
}
