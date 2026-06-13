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

local function can_build_parsers()
	return vim.fn.executable("tree-sitter") == 1
end

M.setup = function()
	local nts = require("nvim-treesitter")
	assert(type(nts.setup) == "function", "nvim-treesitter setup not found")
	assert(type(nts.install) == "function", "nvim-treesitter install not found")

	nts.setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	if can_build_parsers() then
		pcall(function()
			nts.install(ensure_installed)
		end)
	end

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
end

M.spec = function()
	return {
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
	}
end

return M
