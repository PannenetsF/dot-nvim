--- This module provides code action for lsp
--- @module vimspec.edition.dressing
local M = {}

M.spec = function()
	return {
		"stevearc/dressing.nvim",
		event = "VeryLazy",
	}
end

return M
