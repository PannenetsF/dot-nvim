--- Enhanced Vim marks and annotated bookmarks.
--- @module vimspec.navigation.marks

local M = {}

M.which_key_groups = {
	{ "m", group = "Marks", mode = "n" },
}

M.setup = function()
	require("marks").setup({
		default_mappings = true,
		builtin_marks = { ".", "<", ">", "^" },
		cyclic = true,
		force_write_shada = false,
		refresh_interval = 250,
		sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
		excluded_filetypes = {},
		excluded_buftypes = {},
		bookmark_0 = {
			sign = "M",
			virt_text = "",
			annotate = true,
		},
		mappings = {
			set_bookmark0 = "m0",
			next_bookmark = false,
			prev_bookmark = false,
			next_bookmark0 = "m}",
			prev_bookmark0 = "m{",
			annotate = "m?",
		},
	})
end

M.spec = function()
	return {
		"chentoast/marks.nvim",
		event = "VeryLazy",
		keys = {
			{ "m/", "<cmd>BookmarksListAll<CR>", desc = "List Bookmarks", mode = "n" },
			{ "m|", "<cmd>MarksListAll<CR>", desc = "List All Marks", mode = "n" },
			{ "m\\", "<cmd>MarksListBuf<CR>", desc = "List Buffer Marks", mode = "n" },
		},
		config = function()
			M.setup()
		end,
	}
end

return M
