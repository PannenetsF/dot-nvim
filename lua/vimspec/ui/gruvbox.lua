--- Load gruvbox theme
--- @module vimspec.ui.gruvbox
local M = {}

M.setup = function()
	vim.opt.background = "dark" -- set this to dark or light
	vim.cmd.colorscheme("gruvbox-material")
end

M.spec = function()
	return {
		"sainnhe/gruvbox-material",
	}
end

return M
