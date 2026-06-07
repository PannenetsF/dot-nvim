--- set up toggleterm
--- @module vimspec.programming.toggleterm

local M = {}
local fn = require("utils.functions")

M.root_patterns = {
	".git",
	"package.json",
	"pyproject.toml",
	"go.mod",
	"Cargo.toml",
	"Makefile",
	"flake.nix",
	"deno.json",
	"mix.exs",
}

M.project_root = function(dir)
	local cwd = (vim.uv or vim.loop).cwd()
	local target = vim.fs.normalize(vim.fn.expand(dir or cwd))

	if vim.fn.isdirectory(target) == 0 then
		target = vim.fs.dirname(target) or target
	end

	return vim.fs.root(target, M.root_patterns) or target
end

M.project_name = function(dir)
	local root = M.project_root(dir)
	local name = vim.fn.fnamemodify(root, ":t")
	return name ~= "" and name or root
end

M.update_term_title = function(term)
	if term == nil then
		return nil
	end

	local name = M.project_name(term.dir)
	term.display_name = name

	if term.bufnr and vim.api.nvim_buf_is_valid(term.bufnr) then
		vim.b[term.bufnr].toggleterm_project_name = name
	end

	return name
end

M.normal_key_map = {
	t = {
		name = "Terminal",
		f = { "<cmd>ToggleTerm direction=float<cr>", "Floating terminal" },
		t = { "<cmd>ToggleTerm direction=tab<cr>", "Table terminal" },
		v = { "<cmd>2ToggleTerm size=20 direction=vertical<cr>", "Vertical terminal" },
		h = { "<cmd>2ToggleTerm size=20 direction=horizontal<cr>", "Horizontal terminal" },
		s = { "<cmd>ToggleTermSendVisualLines size=20 direction=horizontal<cr>", "Horizontal terminal" },
		a = { "<cmd>ToggleTermToggleAll<cr>", "Toggle all terminals" },
	},
}

--- find shell in order, zsh > bash > sh
M.setup = function()
	require("toggleterm").setup({
		shell = fn.find_shell(),
		autochdir = true,
		on_create = M.update_term_title,
		on_open = M.update_term_title,
		winbar = {
			enabled = true,
			name_formatter = function(term)
				local name = M.update_term_title(term) or "terminal"
				return string.format("%d:%s", term.id, name)
			end,
		},
	})
end
M.spec = function()
	return {
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = {
			"ToggleTerm",
			"ToggleTermSendCurrentLine",
			"ToggleTermSendVisualLines",
			"ToggleTermSendVisualSelection",
			"ToggleTermToggleAll",
		},
	}
end

return M
