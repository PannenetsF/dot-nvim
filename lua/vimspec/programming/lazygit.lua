--- LazyGit
--- @module vimspec.programming.lazygit
local M = {}

M.normal_key_map = {
	["g"] = { "<cmd>LazyGit<CR>", "Toggle LazyGit" },
}

M.spec = function()
	return {
		"kdheepak/lazygit.nvim",
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
