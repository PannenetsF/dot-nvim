--- Load catppuccin theme
--- @module vimspec.ui.catppuccin
local M = {}

M.setup = function()
	vim.cmd.colorscheme("catppuccin")
end

M.spec = function()
	return {
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		flavour = "", -- latte, frappe, macchiato, mocha
		background = { -- :h background
			light = "latte",
			dark = "mocha",
		},
		config = function()
			require("catppuccin").setup()
			M.setup()
		end,
	}
end

return M
