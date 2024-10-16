local client = vim.lsp.start_client({
	name = "educationalsp",
	cmd = { "R --slave -f /Users/thays/Projects/r/educationalsp-r/main.R" },
})

if not client then
	vim.notify("Failed to load client")
	return
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "r",
	callback = function()
		vim.notify("Attaching!")
		vim.lsp.buf_attach_client(0, client)
	end,
})
