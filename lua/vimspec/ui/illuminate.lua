--- This module provides configuration and key mappings for the illuminate plugin
--- @module vimspec.edition.illuminate

local M = {}

M.spec = function()
	return {
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure({
				-- The treesitter provider still depends on nvim-treesitter.locals,
				-- which is brittle with newer nvim-treesitter / Neovim releases.
				providers = { "lsp", "regex" },
			})
		end,
	}
end

return M
