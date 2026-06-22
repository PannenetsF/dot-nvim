--- GitSigns
--- @module vimspec.programming.gitsigns
local M = {}

M.spec = function()
	return {
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "<localleader>gb", "<cmd>Gitsigns blame<CR>", desc = "Open git blame", mode = "n" },
		},
		config = function()
			require("gitsigns").setup({ current_line_blame = true, current_line_blame_opts = {
				delay = 200,
			} })
		end,
	}
end

return M
