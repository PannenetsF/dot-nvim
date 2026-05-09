--- diffview
--- @module vimspec.programming.diffview
local M = {}

M.spec = function()
	return {
		"sindrets/diffview.nvim",
		cmd = { "DiffviewFileHistory", "DiffviewOpen", "DiffviewRefresh", "DiffviewClose", "DiffviewToggleFiles" },
	}
end

return M
