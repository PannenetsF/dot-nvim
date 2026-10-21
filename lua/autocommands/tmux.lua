--- hide tmux status when opening nvim inside tmux
--- @module autocommands.tmux

local M = {}

M.setup_autocmd = function()
	local utils = require("utils.functions")

	-- Outside tmux (plain terminal, GUI, headless) there is no client whose
	-- status line could be toggled and `tmux set ...` just fails with "no
	-- server running". Skip the autocommands entirely.
	if utils.envvar("TMUX") == nil or not utils.executable("tmux") then
		return
	end

	local group = vim.api.nvim_create_augroup("AutoHideTmuxStatus", { clear = true })

	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		pattern = "*",
		callback = function()
			vim.fn.system({ "tmux", "set", "status", "off" })
		end,
	})
	vim.api.nvim_create_autocmd("VimLeave", {
		group = group,
		pattern = "*",
		callback = function()
			vim.fn.system({ "tmux", "set", "status", "on" })
		end,
	})
end

return M
