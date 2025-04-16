--- set the preference of every plugin
--- @module vimspec

local loader = require("utils.loader")
local M = {}

--- load all spec for lazy
M.setup_lazy = function()
    found = {}
    this_file = debug.getinfo(1, "S").source:sub(2)
    this_dir = loader.get_dir(this_file)
    this_dir_lua = loader.get_lua_files_recursively(this_dir)
    name2found = {}
    for _, file in ipairs(this_dir_lua) do
        relpath = loader.relative_path(file)
        mod = require(relpath)
        if mod.spec then
            -- append to list
            print('spec found for: ' .. this_dir .. ' ' .. relpath)
            table.insert(found, mod.spec())
            name2found[relpath] = mod
        end
    end
    M.name2found = name2found
    return found
end

--- setup for every plugin
M.setup = function()
    -- name2found
    -- print name
    for name, mod in pairs(M.name2found) do
        if mod.setup then
            mod.setup()
        end
    end
end

return M
