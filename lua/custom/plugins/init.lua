-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	{
		"R-nvim/R.nvim",
		-- Only required if you also set defaults.lazy = true
		lazy = false,
		-- R.nvim is still young and we may make some breaking changes from time
		-- to time. For now we recommend pinning to the latest minor version
		-- like so:
		version = "~0.1.0",
		config = function()
			-- Create a table with the options to be passed to setup()
			local opts = {
				hook = {
					on_filetype = function()
						vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
						vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
					end,
				},
				min_editor_width = 72,
				rconsole_width = 78,
				pipe_version = "magrittr",
				disable_cmds = {
					"RClearConsole",
					"RCustomStart",
					"RPlot",
					"RSPlot",
					"RSaveClose",
					"RPackages",
					"RShowRout",
					"RSendFile",
					"RMakePDFKb",
					"RMakeAll",
					"RMakeHTML",
					"RMakeODT",
					"RMakePDFK",
					"RMakeWord",
					"RMakeRmd",
					"RListSpace",
					"RClearAll",
					"RSetwd",
					"RObjectStr",
					"RSummary",
					"RSendParagraph",
					"RDSendSelection",
					"RDSendMBlock",
					"RSendAboveLines",
					"RNRightPart",
					"RNLeftPart",
					"RSendMotion",
					"RSendMBlock",
				},
			}
			require("r").setup(opts)
		end,
	},
	{
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>re", "<cmd>IronRepl<cr>", desc = "Start REPL" },
		},
		config = function()
			local iron = require("iron.core")
			iron.setup({
				config = {
					-- Highlights the last sent block with bold
					highlight_last = "IronLastSent",
					-- Toggling behavior is on by default.
					-- Other options are: `single` and `focus`
					visibility = require("iron.visibility").toggle,
					-- Scope of the repl
					-- By default it is one for the same `pwd`
					-- Other options are `tab_based` and `singleton`
					scope = require("iron.scope").path_based,
					-- Whether the repl buffer is a "throwaway" buffer or not
					scratch_repl = false,
					-- Automatically closes the repl window on process end
					close_window_on_exit = true,
					repl_definition = {
						python = require("iron.fts.python").ipython,
					},
					-- Repl position. Check `iron.view` for more options,
					-- currently there are four positions: left, right, bottom, top,
					-- the param is the width/height of the float window
					repl_open_cmd = require("iron.view").split.horizontal.botright(0.4),
					-- If the repl buffer is listed
					buflisted = false,
				},
				keymaps = {
					visual_send = "<enter>",
					send_line = "<enter>",
					interrupt = "<space>qi",
					exit = "<space>qq",
					clear = "<space>qc",
				},
			})
		end,
	},
}

-- vim: ts=2 sts=2 sw=2 et
