-- This module provides grug-far
--- @module vimspec.edition.grug-far

local M = {}

M.which_key_groups = {
	{ "<localleader>f", group = "Find/Replace", mode = "n" },
}

M.spec = function()
	return {
		"MagicDuck/grug-far.nvim",
		keys = {
			{
				"<localleader>ff",
				function()
					require("grug-far").open({ transient = true })
				end,
				desc = "Open GrugFar",
				mode = "n",
			},
			{
				"<localleader>fc",
				function()
					require("grug-far").open({ transient = true, prefills = { paths = vim.fn.expand("%") } })
				end,
				desc = "Open GrugFar for current file",
				mode = "n",
			},
		},
	}
end

return M
