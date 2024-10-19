return {
	{
		"nvim-treesitter/nvim-treesitter-context",
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs", -- Sets main module to use for opts
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"python",
				"rust",
				"r",
				"rnoweb",
				"vim",
				"vimdoc",
				"yaml",
			},
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
				-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
				--  If you are experiencing weird indenting issues, add the language to
				--  the list of additional_vim_regex_highlighting and disabled languages for indent.
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "tv",
					node_incremental = "v",
					scope_incremental = "V",
					node_decremental = "<C-v>",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					include_surrounding_whitespace = false,
					keymaps = {
						["af"] = "@function.outer",
						["aa"] = "@top_level_function",
						["if"] = "@function.inner",
						["as"] = "@statement.outer",
					},
				},
				move = {
					enable = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]s"] = "@statement.outer",
						["]d"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]S"] = "@statement.outer",
						["]D"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[s"] = "@statement.outer",
						["[d"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[S"] = "@statement.outer",
						["[D"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
					},
				},
			},
		},
		-- There are additional nvim-treesitter modules that you can use to interact
		-- with nvim-treesitter. You should go explore a few and see what interests you:
		--
		--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
		--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
		--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	},
}
