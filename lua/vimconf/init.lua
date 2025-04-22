--- set the preference of every vim conf
--- @module vimconf

local loader = require("utils.loader")
local M = {}

--- setup for every pieces of conf
M.setup = function()
	found = {}
	this_file = debug.getinfo(1, "S").source:sub(2)
	this_dir = loader.get_dir(this_file)
	this_dir_lua = loader.get_lua_files_recursively(this_dir)
	name2found = {}
	for _, file in ipairs(this_dir_lua) do
		relpath = loader.relative_path(file)
		mod = require(relpath)
		if mod.conf then
			mod.conf()
		end
	end
end

return M
