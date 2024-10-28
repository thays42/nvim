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
		end,
	},
}
