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
    opts = {},
  },

  -- Follow markdown links (internal and external)
  {
    'jghauser/follow-md-links.nvim',
    ft = { 'markdown' },
  },
}
