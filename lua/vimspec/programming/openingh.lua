--- Open in GH, goto the remote file link
--- @module vimspec.programming.openingh
local M = {}

M.spec = function()
	return {
		"Almo7aya/openingh.nvim",
		cmd = "OpenInGHFileLines",
		keys = {
			{ "gy", "<cmd>OpenInGHFileLines!+<CR>", desc = "Copy Perm Link GitHub", mode = "n" },
			{ "gy", ":OpenInGHFileLines!+<CR>", desc = "Copy Perm Link GitHub", mode = "v" },
		},
		init = function()
			vim.g.openingh_copy_to_register = true
		end,
	}
end

return M
