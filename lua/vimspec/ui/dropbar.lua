--- This module provides configuration and key mappings for the dropbar plugin
--- @module vimspec.edition.dropbar

local M = {}

M.spec = function()
	return {
		"Bekaboo/dropbar.nvim",
		keys = {
			{ "<leader>bs", "<cmd>lua require('dropbar.api').pick()<cr>", desc = "Focus on dropbar", mode = "n" },
			{
				"[;",
				"<cmd>lua require('dropbar.api').goto_context_start()<CR>",
				desc = "Go to start of current context",
				mode = "n",
			},
			{
				"];",
				"<cmd>lua require('dropbar.api').select_next_context()<CR>",
				desc = "Select next context",
				mode = "n",
			},
		},
	}
end
return M
