-- https://www.youtube.com/watch?v=HlfjpstqXwE
local attach_to_buffer = function(output_bufnr, command, pattern, title)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("onwrite", { clear = true }),
		pattern = pattern,
		callback = function(_)
			local append_data = function(_, data)
				if data then
					vim.api.nvim_buf_set_lines(output_bufnr, -1, -1, false, data)
				end
			end
			vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { title })
			vim.fn.jobstart(command, {
				stdout_buffered = true,
				on_stdout = append_data,
				on_stderr = append_data,
			})
		end,
	})
end

-- Create a :command...
vim.api.nvim_create_user_command("AutoRun", function()
	print("AutoRun starts now...")
	local bufnr = vim.fn.input("Bufnr (default: current): ")
	if bufnr == "" then
		bufnr = vim.api.nvim_get_current_buf()
	end
	local pattern = vim.fn.input("Pattern: ")
	local command = vim.fn.input("Command: ")
	local command_split = vim.split(command, " ")

	attach_to_buffer(tonumber(bufnr), command_split, pattern, command)
end, {})

vim.api.nvim_create_user_command("AutoRunClear", function()
	vim.api.nvim_create_augroup("onwrite", { clear = true })
end, {})
