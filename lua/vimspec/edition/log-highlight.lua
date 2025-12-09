--- This module provides log-highlight
--- @module vimspec.edition.log-highlight

local M = {}

M.spec = function()
	return {
		"fei6409/log-highlight.nvim",
		config = function()
			require("log-highlight").setup({
				extension = "log",
				filename = {
					"syslog",
					"log",
				},
				pattern = {
					"%/var%/log%/.*",
					"console%-ramoops.*",
					"log.*%.txt",
					"logcat.*",
					"log.*",
				},
			})
		end,
	}
end

return M
