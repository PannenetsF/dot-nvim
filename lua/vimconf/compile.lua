--- Native compile commands backed by quickfix.
--- @module vimconf.compile

local M = {}

local function quickfix_has_items()
	return #vim.fn.getqflist() > 0
end

local function open_quickfix()
	if quickfix_has_items() then
		vim.cmd.copen()
	end
end

local function compile(opts)
	local ok, err = pcall(vim.api.nvim_cmd, {
		cmd = "make",
		args = opts.fargs,
		mods = { silent = true },
	}, {})

	if not ok then
		vim.notify("Compile failed: " .. err, vim.log.levels.ERROR)
		return
	end

	open_quickfix()
end

local function next_error()
	local ok, err = pcall(vim.cmd.cnext)
	if not ok then
		vim.notify(err, vim.log.levels.WARN)
	end
end

M.conf = function()
	vim.api.nvim_create_user_command("Compile", compile, {
		nargs = "*",
		complete = "file",
		desc = "Run makeprg and populate quickfix",
	})

	vim.api.nvim_create_user_command("CompileNextError", next_error, {
		desc = "Go to the next quickfix error",
	})
end

return M
