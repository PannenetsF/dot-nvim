--- telescope for selection from list
--- @module vimspec.navigation.telescope

local M = {}

--- telescope key mappings for searching files/buffers/help tags/git commits/...
M.normal_key_map = {
	f = {
		name = "Find",
		f = { "<cmd>lua require'telescope.builtin'.find_files{}<cr>", "Find Files" },
		g = { "<cmd>lua require'telescope.builtin'.live_grep{}<cr>", "Live Grep" },
		b = { "<cmd>lua require'telescope.builtin'.buffers{}<cr>", "Buffers" },
		h = { "<cmd>lua require'telescope.builtin'.help_tags{}<cr>", "Help Tags" },
		c = { "<cmd>lua require'telescope.builtin'.git_commits{}<cr>", "Git Commits" },
		l = { "<cmd>Telescope resume<cr>", "Resume last search" },
		H = { "<cmd>Telescope highlights<cr>", "Find highlight groups" },
		r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
		R = { "<cmd>Telescope registers<cr>", "Registers" },
		k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
		C = { "<cmd>Telescope commands<cr>", "Commands" },
		m = { "<cmd>lua require'telescope.builtin'.marks{}<cr>", "Goto Marks" },
		p = {
			"<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
			"Colorscheme with Preview",
		},
	},
	b = {
		name = "Buffers",
		f = { "<cmd>Telescope buffers<cr>", "Buffers" },
	},
}

M.setup = function()
	require("telescope").setup({
		defaults = {
			layout_strategy = "vertical",
			layout_config = {
				vertical = {
					mirror = true,
					prompt_position = "bottom",
					preview_cutoff = 0,
				},
			},
		},
	})
	require("telescope").load_extension("fzf")
end

M.spec = function()
	return {
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
	}
end

return M
