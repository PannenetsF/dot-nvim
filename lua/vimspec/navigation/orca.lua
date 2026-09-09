--- orca-ctl.nvim: drive Orca's worktree/agent daemon over the `orca` CLI
--- @module vimspec.navigation.orca

local M = {}

M.spec = function()
	return {
		"PannenetsF/orca-ctl.nvim",
		cmd = {
			"Orca",
			"OrcaFind",
			"OrcaSwitchProject",
			"OrcaSwitchWorktree",
			"OrcaSwitchAgent",
			"OrcaSend",
			"OrcaPrompt",
			"OrcaOutput",
			"OrcaScreen",
			"OrcaWait",
			"OrcaAgentNew",
			"OrcaWorktrees",
		},
		keys = {
			{ "<leader>af", "<cmd>OrcaFind<cr>", desc = "Orca: find worktree or agent" },
			{ "<leader>ap", "<cmd>OrcaSwitchProject<cr>", desc = "Orca: switch project" },
			{ "<leader>aw", "<cmd>OrcaSwitchWorktree<cr>", desc = "Orca: switch worktree" },
			{ "<leader>aa", "<cmd>OrcaSwitchAgent<cr>", desc = "Orca: switch agent" },
			{ "<leader>ao", "<cmd>Orca<cr>", desc = "Orca: explorer" },
			{ "<leader>ai", "<cmd>OrcaWait<cr>", desc = "Orca: wait for idle" },
			{ "<leader>as", "<cmd>OrcaSend<cr>", mode = "v", desc = "Orca: send selection" },
		},
	}
end

M.setup = function()
	require("orcactl").setup({ agent = "claude" })
end

return M
