--- load neogit
--- @module vimspec.programming.neogit
local M = {}

M.which_key_groups = {
	{ "<localleader>g", group = "Git", mode = "n" },
}

M.spec = function()
	return {
		"NeogitOrg/neogit",
		lazy = true,
		keys = {
			{ "<localleader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit", mode = "n" },
		},
		dependencies = {
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"ibhagwan/fzf-lua", -- optional
			"nvim-mini/mini.pick", -- optional
			"folke/snacks.nvim", -- optional
		},
		cmd = "Neogit",
	}
end

return M
