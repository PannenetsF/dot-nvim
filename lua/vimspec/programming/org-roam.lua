--- set up orgmode
--- @module vimspec.programming.orgmode

local M = {}
--- find shell in order, zsh > bash > sh
M.setup = function()
	local base = "~/Documents/notes"
	require("org-roam").setup({
		directory = base,
		-- optional
		org_files = {
			base .. "/*/**",
		},
		bindings = {
			-- prefix = "<LocalLeader>n",
		},
	})
end
M.spec = function()
	return {
		"chipsenkbeil/org-roam.nvim",
		dependencies = {
			"nvim-orgmode/orgmode",
		},
	}
end

return M
