--- Auto-save configuration module for Neovim
--- @module vimspec.edition.auto-save

local opts = {
	execution_message = {
		message = function() -- message to print on save
			return ""
		end,
		dim = 0.18, -- dim the color of `message`
		cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
	},
}
local M = {}
M.setup = function()
	require("auto-save").setup(opts)
end

M.spec = function()
	return {
		"Pocco81/auto-save.nvim",
	}
end

return M
