--- compile-mode
--- @module vimspec.programming.compile_mode
local M = {}

M.sparse_key_map = {
	{ "<space>ac", ":Compile <CR>", desc = "Compile this project", mode = "n" },
	{ "<space>an", ":CompileNextError <CR>", desc = "Goto next compile error", mode = "n" },
}

M.spec = function()
	return {
		"ej-shafran/compile-mode.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			vim.g.compile_mode = {
				input_word_completion = true,
			}
		end,
	}
end

return M
