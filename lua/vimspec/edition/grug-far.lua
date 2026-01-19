-- This module provides grug-far
--- @module vimspec.edition.grug-far

local M = {}

function M.setup() end

M.sparse_key_map = {
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
}

M.spec = function()
	return {
		"MagicDuck/grug-far.nvim",
	}
end

return M
