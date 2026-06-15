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
	"regex",
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

local function parser_dir()
	return vim.fn.stdpath("data") .. "/site/parser"
end

local function query_dir()
	return vim.fn.stdpath("data") .. "/site/queries"
end

local function copy_dir(source, target)
	vim.fn.mkdir(target, "p")

	for name, kind in vim.fs.dir(source) do
		local source_path = vim.fs.joinpath(source, name)
		local target_path = vim.fs.joinpath(target, name)

		if kind == "directory" then
			copy_dir(source_path, target_path)
		else
			local ok, err = vim.uv.fs_copyfile(source_path, target_path)
			if not ok then
				error(err)
			end
		end
	end
end

local function remove_parser(lang)
	for _, ext in ipairs({ ".so", ".dylib", ".dll" }) do
		vim.fs.rm(vim.fs.joinpath(parser_dir(), lang .. ext), { force = true })
	end
end

local function materialize_legacy_query_links()
	for _, lang in ipairs(ensure_installed) do
		local path = vim.fs.joinpath(query_dir(), lang)
		local stat = vim.uv.fs_lstat(path)

		if stat and stat.type == "link" then
			local target = vim.fn.resolve(path)
			if target:find("/lazy/nvim%-treesitter/runtime/queries/", 1) and vim.fn.isdirectory(target) == 1 then
				local tmp = path .. ".tmp"
				vim.fs.rm(tmp, { recursive = true, force = true })
				copy_dir(target, tmp)
				vim.fs.rm(path, { recursive = true, force = true })
				vim.uv.fs_rename(tmp, path)
			elseif target:find("/lazy/nvim%-treesitter/", 1) then
				vim.fs.rm(path, { recursive = true, force = true })
				remove_parser(lang)
			end
		end
	end
end

M.setup = function()
	materialize_legacy_query_links()

	require("tree-sitter-manager").setup({
		parser_dir = parser_dir(),
		query_dir = query_dir(),
		ensure_installed = ensure_installed,
		highlight = false,
		nerdfont = true,
	})

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
		"romus204/tree-sitter-manager.nvim",
		lazy = false,
	}
end

return M
