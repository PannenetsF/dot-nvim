--- WhichKey configuration module
--- Handles global and plugin-specific key mappings for WhichKey.nvim
--- Provides functionality to:
--- 1. Set global leader key
--- 2. Load plugin-specific keymaps from directory structure
--- 3. Merge and register keymaps with WhichKey
--- @module vimspec.keymapping
local M = {}
local utils = require("utils.loader")

--- sparse keymap
--- @table which_key_nmap
--- @field [string] table
local which_key_sparse_map = {}

--- Normal mode key mappings table
--- @table which_key_nmap
--- @field [string] table Key-value pairs of mappings (e.g., {f = {function() end, "Find file"}})
local which_key_nmap = {}

--- Terminal mode key mappings table
--- @table which_key_tmap
--- @field [string] table Key-value pairs of mappings (e.g., {f = {function() end, "Find file"}})
local which_key_tmap = {}

--- Terminal mode WhichKey options
--- @table which_key_topt
local which_key_topt = {
	mode = "t",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = true,
}
--- Normal mode WhichKey options
--- @table which_key_nopt
--- @field mode string 'n' for normal mode
--- @field prefix string Leader key prefix ('<leader>')
--- @field buffer number|nil Target buffer (nil for global)
--- @field silent boolean Whether to create silent mappings
--- @field noremap boolean Whether to create non-recursive mappings
--- @field nowait boolean Whether to bypass WhichKey timeout
local which_key_nopt = {
	mode = "n",
	prefix = "<leader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = true,
}

--- Visual mode key mappings table
--- @table which_key_vmap
local which_key_vmap = {}

--- Visual mode WhichKey options
--- @table which_key_vopt
local which_key_vopt = {
	mode = "v",
	prefix = "<leader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = true,
}

--- Local leader key mappings table
--- @table which_key_local_nmap
local which_key_local_nmap = {}

--- Local leader WhichKey options
--- @table which_key_local_nopt
local which_key_local_nopt = {
	mode = "n",
	prefix = "<localleader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = true,
}

--- Loads plugin-specific key mappings from directory structure
--- Scans lua/vimspec/ directory for:
--- 1. normal_key_map.lua - Normal mode mappings
--- 2. visual_key_map.lua - Visual mode mappings
--- 3. normal_local_key_map.lua - Local leader mappings
--- Merges found mappings into respective tables
--- @function M.load_plugin_specific
M.load_plugin_specific = function()
	local normal_map = utils.load_from_directory(vim.fn.stdpath("config") .. "/lua/vimspec/", "normal_key_map")
	which_key_nmap = vim.tbl_extend("force", which_key_nmap, normal_map)
	local visual_map = utils.load_from_directory(vim.fn.stdpath("config") .. "/lua/vimspec/", "visual_key_map")
	which_key_vmap = vim.tbl_extend("force", which_key_vmap, visual_map)
	local terminal_map = utils.load_from_directory(vim.fn.stdpath("config") .. "/lua/vimspec/", "terminal_key_map")
	which_key_tmap = vim.tbl_extend("force", which_key_tmap, terminal_map)
	local local_map = utils.load_from_directory(vim.fn.stdpath("config") .. "/lua/vimspec/", "normal_local_key_map")
	which_key_local_nmap = vim.tbl_extend("force", which_key_local_nmap, local_map)
	local sparse_map = utils.concat_lists_from_dir(vim.fn.stdpath("config") .. "/lua/vimspec/", "sparse_key_map")
	which_key_sparse_map = vim.tbl_extend("force", which_key_sparse_map, sparse_map)
end

--- Recursively merges key mapping tables with configuration options
--- Handles both simple key commands and nested key groups
--- @param input_table table The source key mappings table
--- @param config_table table WhichKey configuration options
--- @return table Formatted mappings table ready for WhichKey registration
--- @local
local function merge_tables(input_table, config_table)
	local merged_table = {}
	local prefix = config_table.prefix or ""
	local mode = config_table.mode or ""
	local noremap = config_table.noremap or false
	local nowait = config_table.nowait or false
	local silent = config_table.silent or false

	--- Adds a single key mapping to the merged table
	--- @param keys string The key sequence (without prefix)
	--- @param command string|function The command or function to execute
	--- @param desc string Description for WhichKey to display
	--- @local
	local function add_to_merged_table(keys, command, desc)
		local entry = {
			prefix .. keys,
			command,
			desc = desc,
			nowait = nowait,
			remap = not noremap,
			mode = mode,
		}
		table.insert(merged_table, entry)
	end

	--- Processes nested key groups recursively
	--- @param sub_table table The subgroup of key mappings
	--- @param prefix_keys string Accumulated key prefix from parent groups
	--- @local
	local function process_sub_table(sub_table, prefix_keys)
		for key, value in pairs(sub_table) do
			if type(key) == "string" and #key == 1 then
				if type(value) == "table" and value.name then
					table.insert(
						merged_table,
						{ prefix .. prefix_keys .. key, group = value.name, nowait = true, remap = false }
					)
					process_sub_table(value, prefix_keys .. key)
				else
					add_to_merged_table(prefix_keys .. key, value[1], value[2])
				end
			else
				if type(value) == "table" then
					for k, v in pairs(value) do
						if type(v) == "table" then
							add_to_merged_table(prefix_keys .. key .. k, v[1], v[2])
						end
					end
				end
			end
		end
	end

	-- Main merge logic
	for key, value in pairs(input_table) do
		if type(key) == "string" and #key == 1 then
			if type(value) == "table" and value.name then
				table.insert(merged_table, { prefix .. key, group = value.name, nowait = true, remap = false })
				process_sub_table(value, key)
			else
				add_to_merged_table(key, value[1], value[2])
			end
		else
			config_table[key] = value
		end
	end

	return merged_table
end

--- Main setup function for the module
--- 1. Sets global leader key
--- 2. Loads plugin-specific mappings
--- 3. Registers all mappings with WhichKey
--- @function M.setup
M.setup = function()
	M.load_plugin_specific()
	require("which-key").add(merge_tables(which_key_nmap, which_key_nopt))
	require("which-key").add(merge_tables(which_key_vmap, which_key_vopt))
	require("which-key").add(merge_tables(which_key_tmap, which_key_topt))
	require("which-key").add(merge_tables(which_key_local_nmap, which_key_local_nopt))
	-- sparse map is a list
	require("which-key").add(which_key_sparse_map)
end

M.spec = function()
	return {
		"folke/which-key.nvim",
		cmd = "WhichKey",
		event = "VeryLazy",
		config = function()
			M.setup()
		end,
	}
end

return M
