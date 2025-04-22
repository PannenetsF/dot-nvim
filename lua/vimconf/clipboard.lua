--- setup clipboard with OSC52
--- @module vimconf.clipboard

local M = {}

M.load_clipboard = function()
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = require("vim.ui.clipboard.osc52").paste("+"),
			["*"] = require("vim.ui.clipboard.osc52").paste("*"),
		},
	}

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank()
			local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
			copy_to_unnamedplus(vim.v.event.regcontents)
			local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
			copy_to_unnamed(vim.v.event.regcontents)
		end,
	})
end

M.conf = function()
	M.load_clipboard()
end

return M
