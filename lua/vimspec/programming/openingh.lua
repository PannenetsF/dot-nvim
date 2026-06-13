--- Open in GH, goto the remote file link
--- @module vimspec.programming.openingh
local M = {}

--- define the lsp-related keymaps
M.sparse_key_map = {
	{ "go", ":OpenInGHFileLines! <CR>", desc = "Open in Perm Link GitHub", mode = "n" },
	{ "go", ":OpenInGHFileLines! <CR>", desc = "Open in Perm Link GitHub", mode = "v" },
	{ "gy", ":OpenInGHFileLines!+ <CR>", desc = "Copy Perm Link GitHub", mode = "n" },
	{ "gy", ":OpenInGHFileLines!+ <CR>", desc = "Copy Perm Link GitHub", mode = "v" },
}

M.spec = function()
	return {
		"Almo7aya/openingh.nvim",
		cmd = "OpenInGHFileLines",
		init = function()
			vim.g.openingh_copy_to_register = true
		end,
	}
end

return M
