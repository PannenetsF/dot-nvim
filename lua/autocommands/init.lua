--- autocommands module keeps all the autocommands 
--- most of them are from viml
--- @module autocommands
local M = {}

M.setup = function ()
    require('autocommands.largefile')
end

return M