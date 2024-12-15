return {
  "pappasam/nvim-repl",
  init = function()
    vim.g["repl_filetype_commands"] = {
      python = "ipython --no-autoindent",
      r = "R",
    }
    vim.g["repl_split"] = 'bottom'
  end,
}
