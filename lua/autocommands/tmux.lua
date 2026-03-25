--- hide tmux when opening nvim
--- @module autocommands.tmux

local M = {}

M.setup_autocmd = function()
	-- Set up autocommands
	vim.api.nvim_create_autocmd("VimEnter", {
		pattern = "*",
		command = "silent !tmux set status off",
	})
	vim.api.nvim_create_autocmd("VimLeave", {
		pattern = "*",
		command = "silent !tmux set status on",
	})
end

return M
