--- the module manager uses lazy to manage all plugins
--- @module manager
local M = {}

M.setup = function ()
    require('manager.load')
end

return M