--- compile-mode
--- @module vimspec.programming.compile_mode
local M = {}

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
