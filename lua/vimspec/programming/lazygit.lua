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
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	}
end

return M
