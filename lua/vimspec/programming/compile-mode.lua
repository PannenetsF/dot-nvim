--- Native compile keymaps
--- @module vimspec.programming.compile_mode
local M = {}

M.normal_key_map = {
	a = {
		name = "Code actions",
		c = { ":Compile <CR>", "Compile this project" },
		n = { ":CompileNextError <CR>", "Goto next compile error" },
	},
}

return M
