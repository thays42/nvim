return {
  "R-nvim/R.nvim",
  lazy = false,
  config = function ()
    -- Create a table with the options to be passed to setup()
    local opts = {
      hook = {
        on_filetype = function()
          vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
          vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
        end
      },
      min_editor_width = 72,
      rconsole_width = 78,
      disable_cmds = {
          "RClearConsole",
          "RCustomStart",
          "RSPlot",
          "RSaveClose",
        },
      }
    require("r").setup(opts)
  end,
}
