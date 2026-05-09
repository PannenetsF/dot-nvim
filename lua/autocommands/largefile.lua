--- Large file handling (10MB threshold)
--- if the file size is larger than 10MB, disable certain features
--- like relative number, swapfile, and undo levels
--- and set the buffer type to "nowrite"
--- @module autocommands.largefile
local large_file_size = 10485760 -- 10MB

local function add_eventignore(values)
	local current = vim.opt.eventignore:get()
	for _, value in ipairs(values) do
		if not vim.tbl_contains(current, value) then
			table.insert(current, value)
		end
	end
	vim.opt.eventignore = current
	return current
end

local function handle_large_file(ev)
	local bufnr = ev.buf
	local f = ev.file
	-- use vim.loop.fs_stat for better performance than vim.fn.getfsize
	local status, stats = pcall(vim.loop.fs_stat, f)

	if not status or not stats then
		return
	end

	if stats.size > large_file_size then
		vim.b[bufnr].dotnvim_large_file = true
		vim.b[bufnr].dotnvim_restore_eventignore = vim.opt.eventignore:get()

		-- Prevent filetype plugins from starting heavy per-file features before
		-- the large-file buffer has a chance to opt out.
		add_eventignore({ "FileType", "Syntax" })

		-- Disable heavy features locally
		vim.opt_local.swapfile = false
		vim.opt_local.bufhidden = "unload"
		vim.opt_local.buftype = "nowrite"
		vim.opt_local.undolevels = -1
		vim.opt_local.foldmethod = "manual"
		vim.opt_local.foldexpr = "0"
		vim.opt_local.syntax = "off"
		vim.opt_local.statuscolumn = ""
		vim.opt_local.signcolumn = "no"
		vim.opt_local.cursorline = false
		vim.opt_local.cursorcolumn = false
		vim.opt_local.list = false
		vim.opt_local.wrap = false
		vim.opt_local.relativenumber = false
		vim.opt_local.number = true -- keep absolute number

		-- Schedule disabling of LSP and Treesitter after they might have been enabled by FileType
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			-- Stop Treesitter
			if vim.treesitter.stop then
				vim.treesitter.stop(bufnr)
			end

			-- Detach LSP clients
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			for _, client in ipairs(clients) do
				vim.lsp.buf_detach_client(bufnr, client.id)
			end
		end)

		vim.notify(
			string.format("Large file detected (%s). Performance mode enabled.", vim.fn.fnamemodify(f, ":t")),
			vim.log.levels.WARN
		)
	end
end

local function restore_eventignore(ev)
	local bufnr = ev.buf
	local restore = vim.b[bufnr].dotnvim_restore_eventignore
	if restore ~= nil then
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_call(bufnr, function()
					vim.opt_local.syntax = "off"
				end)
			end
			vim.opt.eventignore = restore
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.b[bufnr].dotnvim_restore_eventignore = nil
			end
		end)
	end
end

local M = {}

M.setup_autocmd = function()
	-- Set up autocommands
	vim.api.nvim_create_augroup("LargeFile", { clear = true })
	vim.api.nvim_create_autocmd("BufReadPre", {
		group = "LargeFile",
		callback = handle_large_file,
	})
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = "LargeFile",
		callback = restore_eventignore,
	})
end

return M
