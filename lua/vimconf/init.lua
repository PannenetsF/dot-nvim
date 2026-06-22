--- set the preference of every vim conf
--- @module vimconf

local loader = require("utils.loader")
local M = {}

--- setup for every pieces of conf
M.setup = function()
	local this_file = debug.getinfo(1, "S").source:sub(2)
	local this_dir = loader.get_dir(this_file)
	local this_dir_lua = loader.get_lua_files_recursively(this_dir)
	table.sort(this_dir_lua)

	local function load_conf(file)
		local relpath = loader.relative_path(file)
		local mod = require(relpath)
		if mod.conf then
			mod.conf()
		end
	end

	for _, file in ipairs(this_dir_lua) do
		if loader.relative_path(file) == "vimconf.easy-opt" then
			load_conf(file)
		end
	end

	for _, file in ipairs(this_dir_lua) do
		local relpath = loader.relative_path(file)
		if relpath ~= "vimconf.easy-opt" and relpath ~= "vimconf" then
			load_conf(file)
		end
	end
end

return M
