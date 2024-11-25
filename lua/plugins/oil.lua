return {
  "stevearc/oil.nvim",
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = { "icon" },
      -- Buffer-local options to use for oil buffers
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      -- Window-local options to use for oil buffers
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      keymaps = {
        ["<C-h>"] = false,
        ["<leader>-q"] = "actions.close",
        ["<leader>-r"] = "actions.refresh",
      },
      view_options = {
        show_hidden = true,
      },
      skip_confirm_for_simple_edits = false
    })
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
}
