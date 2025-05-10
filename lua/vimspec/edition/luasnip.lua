--- setup luasnip
--- @module vimspec.edition.luasnip
local M = {}

M.setup = function()
	require("luasnip.loaders.from_lua").lazy_load()
	require("luasnip.loaders.from_vscode").lazy_load()
	require("luasnip.loaders.from_snipmate").lazy_load()
end

M.spec = function()
	return {
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		dependencies = {
			"friendly-snippets",
			"honza/vim-snippets",
		},
	}
end

return M
