--- LazyGit
--- @module vimspec.programming.lazygit
local M = {}

M.spec = function()
	return {
		"kdheepak/lazygit.nvim",
		keys = {
			{ "<leader>g", "<cmd>LazyGit<CR>", desc = "Toggle LazyGit", mode = "n" },
		},
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		init = function()
			vim.g.lazygit_floating_window_use_plenary = 0
		end,
	}
end

return M
