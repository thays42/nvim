return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = "<leader>;t",
				direction = "float",
			})

			-- Helper for creating terminal commands
			local Terminal = require("toggleterm.terminal").Terminal
			local new_term = function(cmd, dir)
				return Terminal:new({
					cmd = cmd,
					dir = dir,
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
			end

			function ToggleCustomTerminal(terminal)
				local this_terminal = CustomTerminals[terminal]
				if vim.fn.executable(terminal) ~= 1 then
					vim.notify("Terminal toggle command not found: " .. terminal)
				end
				if this_terminal == nil then
					vim.notify("Invalid terminal toggle requested: " .. terminal)
				else
					this_terminal:toggle()
				end
			end

			-- Add terminal definitions here.
			CustomTerminals = {
				lazygit = new_term("lazygit", "git_dir"),
				htop = new_term("htop"),
			}

			-- Add keymappings here.
			vim.api.nvim_set_keymap(
				"n",
				"<leader>;g",
				"<cmd>lua ToggleCustomTerminal('lazygit')<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>;h",
				"<cmd>lua ToggleCustomTerminal('htop')<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
}
