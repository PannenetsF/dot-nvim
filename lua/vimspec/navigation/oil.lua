--- Use oil as a file explorer in buffer
--- @module vimspec.navigation.oil

local M = {}

M.setup = function()
	require("oil").setup()
end

M.spec = function()
	return {
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
		lazy = false,
	}
end
return M
