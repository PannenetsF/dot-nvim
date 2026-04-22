--- setup nvim-hlslens for inline search match count
--- @module vimspec.ui.hlslens

local M = {}

M.setup = function()
	local ok, hlslens = pcall(require, "hlslens")
	if not ok then
		return
	end

	hlslens.setup({
		auto_enable = true,
		enable_incsearch = true,
		calm_down = false,
		nearest_only = false,
		nearest_float_when = "auto",
		float_shadow_blend = 50,
		virt_priority = 100,
		override_lens = nil,
	})

	local kopts = { noremap = true, silent = true }
	vim.api.nvim_set_keymap(
		"n",
		"n",
		[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
		kopts
	)
	vim.api.nvim_set_keymap(
		"n",
		"N",
		[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
		kopts
	)
	vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
	vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
	vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
	vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
end

M.spec = function()
	return {
		"kevinhwang91/nvim-hlslens",
		event = "VeryLazy",
		cond = require("utils.functions").firenvim_not_active,
	}
end

return M
