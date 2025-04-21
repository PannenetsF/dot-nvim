--- setup the basic ui
--- @module.vimconf.ui
local M = {}

M.conf = function()
    vim.opt.termguicolors = true
    vim.o.lazyredraw = true -- Reduces flickering by not redrawing while executing macros
    vim.o.updatetime = 300  -- Reduce the time it takes to trigger the CursorHold event
    vim.opt.colorcolumn = "80" -- Highlight column 80
end

return M
