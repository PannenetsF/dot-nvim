--- fzf-lua for selection from list
--- @module vimspec.navigation.fzf

local M = {}

--- fzf key mappings for searching files/buffers/help tags/git commits/...
M.normal_key_map = {
	f = {
		name = "Find",
		f = { "<cmd>FzfLua files<cr>", "Find Files" },
		F = { "<cmd>FzfLua filetypes<cr>", "Filetypes" },
		g = { "<cmd>FzfLua live_grep<cr>", "Live Grep" },
		b = { "<cmd>FzfLua buffers<cr>", "Buffers" },
		q = { "<cmd>FzfLua lgrep_quickfix<cr>", "Quick Fix" },
		h = { "<cmd>FzfLua help_tags<cr>", "Help Tags" },
		H = { "<cmd>FzfLua highlights<cr>", "Hightlight Group" },
		c = { "<cmd>FzfLua git_commits<cr>", "Git Commits" },
		j = { "<cmd>FzfLua jumps<cr>", "Jump Lines" },
		l = { "<cmd>FzfLua resume<cr>", "Resume last search" },
		s = { "<cmd>FzfLua search_history<cr>", "Open Recent Commands" },
		r = { "<cmd>FzfLua oldfiles<cr>", "Open Recent File" },
		R = { "<cmd>FzfLua registers<cr>", "Registers" },
		k = { "<cmd>FzfLua keymaps<cr>", "Keymaps" },
		t = { "<cmd>FzfLua treesitter<cr>", "Treesitters" },
		C = { "<cmd>FzfLua commands<cr>", "Commands" },
		m = { "<cmd>FzfLua marks<cr>", "Goto Marks" },
		p = { "<cmd>FzfLua colorschemes<cr>", "Colorscheme with Preview" },
		P = { "<cmd>FzfLua awesome_colorschemes<cr>", "Colorscheme with Preview" },
	},
}

M.setup = function() end

M.spec = function()
	return {
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	}
end

return M
