--- entry of nvim
---@file init.lua
---@author Your Name

--- M carries the configuration for the neovim
local M = {}

--- `configure_path` sets the path for the configuration files
function M.configure_path()
	M.lua_conf_dir = vim.fn.stdpath("config") .. "/lua"
end

--- `core_modules` set the core module of nvim
--- autocommands set up needed autocommands
--- vimconf set up the basic nvim configuration, without any plugins
--- manager set up the plugin manager lazy.nvim, which reads from vimspec
--- vimspec describes how to install the plugins and configure them
function M.set_core_modules()
	M.core_modules = {
		"autocommands/",
		"vimconf/",
		"manager/",
		"vimspec/",
	}
end

--- `load_module` loads lua module from the base dir
---@param name string
function M.load_module(name)
	if vim.endswith(name, ".lua") then
		-- if it is a lua file
		local module_name, _ = string.gsub(name, "%.lua", "")
		package.loaded[module_name] = nil
		require(module_name)
	elseif vim.endswith(name, "/") then
		-- if it is a dir
		name = name:sub(1, -2)
		local module = require(name)
		module.setup()
	else
		vim.notify("Unknown file type: " .. name)
	end
end

--- `setup` sets up the core modules
function M.setup()
	M.configure_path()
	M.set_core_modules()
	for _, mod in ipairs(M.core_modules) do
		M.load_module(mod)
	end
end

M.setup()
