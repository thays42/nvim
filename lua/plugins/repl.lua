-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	{
		"Vigemus/iron.nvim",
		enabled = false,
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
						r = require("iron.fts.r").radian,
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
					interrupt = "<space>qi",
					exit = "<space>qq",
					clear = "<space>qc",
				},
			})
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = "<leader>;t",
				direction = "float",
			})
			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({
				cmd = "lazygit",
				dir = "git_dir",
				direction = "float",
				float_opts = {
					border = "double",
				},
				-- function to run on opening the terminal
				on_open = function(term)
					vim.cmd("startinsert!")
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"n",
						"q",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
				-- function to run on closing the terminal
				on_close = function(term)
					vim.cmd("startinsert!")
				end,
			})

			function _lazygit_toggle()
				lazygit:toggle()
			end

			vim.api.nvim_set_keymap(
				"n",
				"<leader>;g",
				"<cmd>lua _lazygit_toggle()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
	{
		"pappasam/nvim-repl",
		init = function()
			vim.g["repl_filetype_commands"] = {
				r = "R",
				python = "ipython --no-autoindent",
			}
			vim.g["repl_split"] = "bottom"
		end,
		keys = {
			{ "<leader>;r", "<cmd>ReplToggle<cr>", desc = "Toggle nvim-repl" },
		},
	},
}
