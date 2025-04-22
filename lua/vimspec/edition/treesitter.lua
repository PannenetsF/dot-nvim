--- setup treesitter
--- @module vimspec.edition.treesitter

local M = {}

M.setup = function()
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"python",
			"cpp",
			"cuda",
			"lua",
			"vim",
			"json",
			"toml",
			"vimdoc",
			"c",
			"bash",
			"markdown",
			"markdown_inline",
			"query",
		},
		ignore_install = {}, -- List of parsers to ignore installing
		highlight = {
			enable = true, -- false will disable the whole extension
			disable = { "help" }, -- list of language that will be disabled
		},
	})
end

M.spec = function()
	return {
		"nvim-treesitter/nvim-treesitter",
		cmd = {
			"TSInstall",
			"TSUninstall",
			"TSUpdate",
			"TSUpdateSync",
			"TSInstallInfo",
			"TSInstallSync",
			"TSInstallFromGrammar",
		},
		event = "VimEnter",
		-- event = "VeryLazy",
		build = ":TSUpdate",
	}
end

return M
