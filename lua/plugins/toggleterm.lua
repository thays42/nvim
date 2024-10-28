return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = "<leader>;t",
				direction = "float",
				size = function(term)
					if term.direction == "horizontal" then
						return vim.o.lines * 0.4
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
			})

			-- Helper for creating terminal commands
			local Terminal = require("toggleterm.terminal").Terminal

			local function q2quit(term)
				vim.cmd("startinsert!")
				vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
			end

			local new_float_term = function(cmd, dir, close_on_exit)
				if close_on_exit == nil then
					close_on_exit = true
				end
				return Terminal:new({
					cmd = cmd,
					dir = dir,
					direction = "float",
					float_opts = {
						border = "double",
					},
					close_on_exit = close_on_exit,
					on_open = q2quit,
					on_close = function(term)
						vim.cmd("startinsert!")
					end,
				})
			end

			local new_repl_term = function(cmd, dir)
				return Terminal:new({
					cmd = cmd,
					dir = dir,
					direction = "horizontal",
					on_open = function(term)
						vim.cmd("startinsert!")
					end,
					on_close = function(term)
						vim.cmd("startinsert!")
					end,
				})
			end

			function ToggleCustomTerminal(terminal)
				local this_terminal = CustomTerminals[terminal]
				if this_terminal == nil then
					vim.notify("Invalid terminal toggle requested: " .. terminal)
				else
					this_terminal:toggle()
				end
			end

			-- Add terminal definitions here.
			CustomTerminals = {
				lazygit = new_float_term("lazygit", "git_dir"),
				htop = new_float_term("htop"),
				bash = new_repl_term("bash"),
				r_repl = new_repl_term("R", nil),
				r_runtests = new_float_term("R --quiet -e 'testthat::test_local()'", nil, false),
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
			vim.api.nvim_set_keymap(
				"n",
				"<leader>;b",
				"<cmd>lua ToggleCustomTerminal('bash')<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>;rt",
				"<cmd>lua ToggleCustomTerminal('r_runtests')<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>;rr",
				"<cmd>lua ToggleCustomTerminal('r_repl')<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
}
