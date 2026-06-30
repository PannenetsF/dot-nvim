--- redraw UI after terminal focus/resume events
--- @module autocommands.redraw

local M = {}

local function redraw()
	vim.defer_fn(function()
		if vim.api.nvim_get_mode().mode ~= "c" then
			vim.cmd("redraw!")
		end
	end, 80)
end

M.setup_autocmd = function()
	local group = vim.api.nvim_create_augroup("AutoRedrawAfterResume", { clear = true })

	vim.api.nvim_create_autocmd({ "FocusGained", "VimResume", "VimResized" }, {
		group = group,
		pattern = "*",
		callback = redraw,
	})
end

return M
