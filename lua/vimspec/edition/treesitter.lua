--- setup treesitter
--- @module vimspec.edition.treesitter

local M = {}

local ensure_installed = {
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
}

local highlight_filetypes = {
	"python",
	"cpp",
	"cuda",
	"lua",
	"vim",
	"help",
	"json",
	"jsonc",
	"toml",
	"c",
	"sh",
	"bash",
	"markdown",
	"query",
}

M.setup = function()
	local nts = require("nvim-treesitter")
	if type(nts.setup) == "function" and type(nts.install) == "function" then
		nts.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		pcall(function()
			nts.install(ensure_installed)
		end)

		vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = "UserTreesitter",
			pattern = highlight_filetypes,
			callback = function(ev)
				if vim.b[ev.buf].dotnvim_large_file or vim.b[ev.buf].dotnvim_treesitter_failed then
					return
				end
				pcall(vim.treesitter.start)
			end,
		})
		return
	end

	local setup = nil
	local ok, _ = pcall(require, "nvim-treesitter.config")
	if ok then
		setup = require("nvim-treesitter.config").setup
	else
		ok, _ = pcall(require, "nvim-treesitter.configs")
		if ok then
			setup = require("nvim-treesitter.configs").setup
		end
	end
	-- assert
	assert(setup, "nvim-treesitter setup not found")
	setup({
		ensure_installed = ensure_installed,
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
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
	}
end

return M
