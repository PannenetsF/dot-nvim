--- Use Vista to View and search LSP symbols, tags in Vim/NeoVim.
--- @module vimspec.navigation.vista

local M = {}

M.setup = function()
	vim.g.vista_default_executive = "ctags"
	vim.g.vista_sidebar_width = 35
	vim.g.vista_sidebar_position = "vertical botright"
	vim.g.vista_stay_on_open = 0
	vim.g.vista_close_on_jump = 0
	vim.g.vista_enable_centering_jump = 1
end

M.normal_key_map = {
	v = {
		name = "Vista",
		v = { "<cmd>Vista!!<cr>", "Toggle Vista" },
		f = { "<cmd>Vista focus<cr>", "Focus Vista" },
		s = { "<cmd>Vista show<cr>", "Show Current Symbol" },
		l = { "<cmd>Vista nvim_lsp<cr>", "Open LSP Outline" },
		c = { "<cmd>Vista ctags<cr>", "Open Ctags Outline" },
		["/"] = { "<cmd>FzfLua lsp_document_symbols<cr>", "Search LSP Symbols" },
		["?"] = { "<cmd>FzfLua treesitter<cr>", "Search Treesitter Symbols" },
	},
}

M.spec = function()
	return {
		"liuchengxu/vista.vim",
		cmd = "Vista",
		init = function()
			M.setup()
		end,
	}
end
return M
