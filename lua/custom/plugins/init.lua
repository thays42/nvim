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
}

-- vim: ts=2 sts=2 sw=2 et
