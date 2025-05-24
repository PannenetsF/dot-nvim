--- load github copilot
--- @module vimspec.programming.copilot
local M = {}

M.setup = function()
	vim.g.copilot_no_tab_map = true
	vim.g.copilot_assume_mapped = true
	vim.g.copilot_tab_fallback = ""
	vim.api.nvim_set_keymap("i", "<C-E>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
end

M.spec = function()
	return { "github/copilot.vim" }
end

return M
