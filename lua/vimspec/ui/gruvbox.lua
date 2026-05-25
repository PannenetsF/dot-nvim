--- Load gruvbox theme
--- @module vimspec.ui.gruvbox
local M = {}

M.setup = function()
	vim.g.gruvbox_material_background = "soft"
	vim.g.gruvbox_material_foreground = "material"
	vim.g.gruvbox_material_better_performance = 1
	vim.cmd.colorscheme("gruvbox-material")
end

M.spec = function()
	return {
		"sainnhe/gruvbox-material",
		priority = 1000,
		config = function()
			M.setup()
		end,
	}
end

return M
