--- load snacks.nvim and configure its features
--- @module vimspec.ui.snacks
local M = {}

M.setup = function()
	-- setup is called by lazy config
end

M.spec = function()
	return {
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			scratch = { enabled = true },
		},
	}
end

return M
