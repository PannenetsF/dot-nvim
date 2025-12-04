--- Load github theme
--- @module vimspec.ui.github
local M = {}

M.setup = function()
	vim.opt.background = "dark" -- set this to dark or light
	-- vim.cmd.colorscheme "github_dark_default"
end

M.spec = function()
	return {
		"projekt0n/github-nvim-theme",
	}
end

return M
