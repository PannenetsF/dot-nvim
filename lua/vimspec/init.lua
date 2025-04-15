--- set the preference of every plugin 
--- @module vimspec

local loader = require("utils.loader")
local M = {}

M.setup = function ()
    found = {}
    this_file = debug.getinfo(1, "S").source:sub(2)
    this_dir = loader.get_dir(this_file)
    this_dir_lua = loader.get_lua_files_recursively(this_dir)
    for _, file in ipairs(this_dir_lua) do
        relpath = loader.relative_path(file)
        mod = require(relpath)
        if mod.spec then
            -- append to list 
            table.insert(found, mod.spec())
        end
    end
    return found
end

return M