--- Load vscode-like minimap
--- @module vimspec.ui.minimap
local M = {}

M.normal_key_map = {
	p = {
		name = "Minimap",
		p = { "<cmd>lua require('mini.map').toggle()<cr>", "Toggle minimap" },
		o = { "<cmd>lua require('mini.map').toggle_focus()<cr>", "Focus on minimap" },
	},
}

M.setup = function()
	require("mini.map").setup()
end
M.spec = function()
	return {
		{ "nvim-mini/mini.map", version = false },
	}
end

return M
