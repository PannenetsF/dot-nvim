--- setup clipboard with OSC52
--- @module vimconf.clipboard

local utils = require("utils.functions")
local M = {}

local function paste()
	return {
		vim.fn.split(vim.fn.getreg(""), "\n"),
		vim.fn.getregtype(""),
	}
end

M.load_clipboard = function()
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},

		paste = {
			["+"] = paste,
			["*"] = paste,
		},
	}

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank()
			utils.copy_to_clipboard()
		end,
	})
end

M.conf = function()
	M.load_clipboard()
end

return M
