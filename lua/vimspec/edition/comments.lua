-- This module provides comment-toggle
--- @module vimspec.edition.comments

local M = {}

function M.setup()
	require("Comment").setup()
end

M.spec = function()
	return {
		"numToStr/Comment.nvim",
		event = "VimEnter",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
	}
end

return M
