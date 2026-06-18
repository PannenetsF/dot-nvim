--- setup the basic ui
--- @module vimconf.ui
local M = {}

M.conf = function()
	vim.opt.termguicolors = true
	vim.o.lazyredraw = false -- Reduces flickering by not redrawing while executing macros
	vim.o.updatetime = 300 -- Reduce the time it takes to trigger the CursorHold event
	vim.opt.colorcolumn = "80" -- Highlight column 80
	vim.opt.cmdheight = 0

	if vim.g.neovide then
		vim.o.guifont = "UbuntuMono Nerd Font Mono:h16"
		vim.g.neovide_cursor_animation_length = 0
		vim.g.neovide_cursor_trail_size = 0
	end
end

return M
