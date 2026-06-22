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

M.which_key_groups = {
	{ "<leader>v", group = "Vista", mode = "n" },
}

M.spec = function()
	return {
		"liuchengxu/vista.vim",
		cmd = "Vista",
		keys = {
			{ "<leader>vv", "<cmd>Vista!!<cr>", desc = "Toggle Vista", mode = "n" },
			{ "<leader>vf", "<cmd>Vista focus<cr>", desc = "Focus Vista", mode = "n" },
			{ "<leader>vs", "<cmd>Vista show<cr>", desc = "Show Current Symbol", mode = "n" },
			{ "<leader>vl", "<cmd>Vista nvim_lsp<cr>", desc = "Open LSP Outline", mode = "n" },
			{ "<leader>vc", "<cmd>Vista ctags<cr>", desc = "Open Ctags Outline", mode = "n" },
			{ "<leader>v/", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Search LSP Symbols", mode = "n" },
			{ "<leader>v?", "<cmd>FzfLua treesitter<cr>", desc = "Search Treesitter Symbols", mode = "n" },
		},
		init = function()
			M.setup()
		end,
	}
end
return M
