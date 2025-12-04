--- typing plugin
--- @module vimspec.programming.typr
local M = {}

M.spec = function()
	return {
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	}
end

return M
