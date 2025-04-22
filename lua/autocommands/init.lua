--- autocommands module keeps all the autocommands
--- most of them are from viml
--- @module autocommands
local M = {}

local loader = require("utils.loader")

M.setup = function()
	this_file = debug.getinfo(1, "S").source:sub(2)
	this_dir = loader.get_dir(this_file)
	this_dir_lua = loader.get_lua_files_recursively(this_dir)
	for _, file in ipairs(this_dir_lua) do
		relpath = loader.relative_path(file)
		mod = require(relpath)
		if mod.setup_autocmd then
			mod.setup_autocmd()
		end
	end
end

return M
