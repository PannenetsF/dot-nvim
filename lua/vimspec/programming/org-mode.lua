--- set up orgmode
--- @module vimspec.programming.orgmode

local M = {}
--- find shell in order, zsh > bash > sh
M.setup = function()
	local Menu = require("org-modern.menu")
	local base = "~/Documents/notes"
	require("orgmode").setup({
		org_agenda_files = base .. "/*/**",
		org_default_notes_file = base .. "/note.org",
		org_adapt_indentation = false,
		org_hide_emphasis_markers = true,
		org_capture_templates = {
			t = { description = "Task", template = "* TODO %?\n  %u" },
			T = { description = "Task from Code", template = "* TODO %F\n %?\n  %u" },
			c = { description = "Catch Mind", template = "* %?\n  %u", target = base .. "/quick.org" },
		},
		mappings = {
			org = {
				org_toggle_checkbox = "cic",
			},
		},
		ui = {
			menu = {
				handler = function(data)
					Menu:new():open(data)
				end,
			},
		},
	})
	require("org-bullets").setup()
end
M.spec = function()
	return {
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		ft = { "org" },
		dependencies = {
			"nvim-orgmode/org-bullets.nvim",
			"danilshvalov/org-modern.nvim",
		},
	}
end

return M
