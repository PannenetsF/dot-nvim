--- Configure file icons used across the UI.
--- @module vimspec.ui.devicons

local M = {}

M.spec = function()
	return {
		"nvim-tree/nvim-web-devicons",
		opts = {
			override_by_extension = {
				yaml = {
					icon = "",
					color = "#D70000",
					cterm_color = "160",
					name = "Yaml",
				},
				yml = {
					icon = "",
					color = "#D70000",
					cterm_color = "160",
					name = "Yml",
				},
			},
		},
	}
end

return M
