--- set the preference of every plugin 
--- @module vimspec

local M = {}

M.setup = function ()
    require('vimspec.keymapping.which-key')
end

return M