--- Shared which-key group labels for core keymaps.
--- @module vimspec.keymapping.groups

local M = {}

M.which_key_groups = {
	{ "<leader>a", group = "Code actions", mode = "n" },
	{ "<leader>y", group = "Yank", mode = { "n", "v" } },
}

return M
