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
		priority = 1000,
		flavour = "", -- latte, frappe, macchiato, mocha
		background = { -- :h background
			light = "latte",
			dark = "mocha",
		},
		config = function()
			require("catppuccin").setup({
				highlight_overrides = {
					latte = function(colors)
						return {
							NeoTreeCursorLine = { fg = colors.lavender, bg = colors.base },
						}
					end,
				},
			})
		end,
	}
end

return M
