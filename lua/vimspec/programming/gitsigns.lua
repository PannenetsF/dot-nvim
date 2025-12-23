--- GitSigns
--- @module vimspec.programming.gitsigns
local M = {}

M.sparse_key_map = {
	{ "<localleader>gb", ":Gitsigns blame<CR>", desc = "Open git blame", mode = "n" },
}

M.spec = function()
	return {
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({ current_line_blame = true, current_line_blame_opts = {
				delay = 200,
			} })
		end,
	}
end

return M
