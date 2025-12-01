--- load neogit
--- @module vimspec.programming.neogit
local M = {}

M.spec = function()
	return {
		"NeogitOrg/neogit",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			"ibhagwan/fzf-lua", -- optional
			"nvim-mini/mini.pick", -- optional
			"folke/snacks.nvim", -- optional
		},
		cmd = "Neogit",
		keys = {
			{ "<localleader>g", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
		},
	}
end

return M
