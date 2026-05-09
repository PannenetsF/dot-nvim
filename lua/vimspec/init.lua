--- set the preference of every plugin
--- @module vimspec

local loader = require("utils.loader")
local M = {}

--- load all spec for lazy
M.setup_lazy = function()
	local found = {}
	local this_file = debug.getinfo(1, "S").source:sub(2)
	local this_dir = loader.get_dir(this_file)
	local this_dir_lua = loader.get_lua_files_recursively(this_dir)
	local name2found = {}
	for _, file in ipairs(this_dir_lua) do
		local relpath = loader.relative_path(file)
		local mod = require(relpath)
		if mod.spec then
			local spec = mod.spec()
			if type(spec) == "table" and mod.setup and spec.config == nil and spec.opts == nil then
				spec.config = function()
					mod.setup()
				end
			end
			table.insert(found, spec)
			name2found[relpath] = mod
		end
	end
	M.name2found = name2found
	return found
end

--- setup for every plugin
M.setup = function()
	-- Plugin setup is attached to each lazy.nvim spec so startup does not
	-- eagerly require plugins that were configured for event/cmd/ft loading.
end

return M
