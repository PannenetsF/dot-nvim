--- This module provides configuration and key mappings for the dropbar plugin
--- @module vimspec.edition.dropbar

local M = {}

M.normal_key_map = {
	b = {
		s = { "<cmd>lua require('dropbar.api').pick()<cr>", "Focus on dropbar" },
	},
}

M.sparse_key_map = {
	{
		"[;",
		":lua require('dropbar.api').goto_context_start()<CR>",
		desc = "Go to start of current context",
		mode = "n",
	},
	{ "];", ":lua require('dropbar.api').select_next_context()<CR>", desc = "Select next context", mode = "n" },
}

M.spec = function()
	return {
		"Bekaboo/dropbar.nvim",
	}
end
return M
