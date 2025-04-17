--- Utility module for file system operations and table manipulations
--- Provides functions for loading and merging Lua modules from directories
--- @module utils.loader
local M = {}

--- Recursively extends a table with another table's contents
--- Handles nested table merging while preserving existing values
--- @param t table The target table to be extended
--- @param ext table The source table containing values to merge
--- @local
local function _extend_table(t, ext)
  for k, v in pairs(ext) do
    if t[k] == nil then
      t[k] = v
    elseif type(t[k]) == "table" and type(v) == "table" then
      _extend_table(t[k], v)
    else
      t[k] = v
    end
  end
end

--- Finds all Lua files in a directory (platform-independent)
--- Uses `dir` on Windows and `find` on Unix-like systems
--- @param path string The directory path to search
--- @return table List of absolute file paths
M.find_luas = function(path)
  if vim.fn.has("win32") == 1 then
    return io.popen('dir /s /b "' .. path .. '\\*.lua"')
  else
    return io.popen('find "' .. path .. '" -type f -name "*.lua"')
  end
end

--- Recursively collects all Lua files from a directory
--- @param path string The base directory path
--- @return table Array containing absolute paths of all found Lua files
M.get_lua_files_recursively = function(path)
  local all_lua_files = {}
  local p = M.find_luas(path)
  if not p then return all_lua_files end
  for file in p:lines() do
    table.insert(all_lua_files, file)
  end
  return all_lua_files
end

--- Recursively sorts a table by its keys
--- Maintains nested table structure while sorting
--- @param t table The table to be sorted
--- @return table New table with sorted keys
--- @local
local function sort_table_recursive(t)
  local keys = {}
  for k in pairs(t) do table.insert(keys, k) end
  table.sort(keys)
  local sorted = {}
  for _, k in ipairs(keys) do
    local v = t[k]
    if type(v) == "table" then
      v = sort_table_recursive(v)
    end
    sorted[k] = v
  end
  return sorted
end

--- Loads a Lua file and merges its specified attribute into target table
--- @param path string Path to the Lua file
--- @param key string The table key to extract from loaded module
--- @param m table The target table to merge into
--- @local
local function load_and_merge(path, key, m)
  local ok, attr = pcall(dofile, path)
  if not ok then return end
  if type(attr) == "table" and attr[key] then
    _extend_table(m, attr[key])
  end
end

--- Core function that merges tables from all Lua files in directory
--- @param path string Directory path to scan
--- @param attr string The attribute key to extract from each module
--- @return table Merged and sorted result table
--- @local
local function merge_tables_from_directories(path, attr)
  local all_lua_files = M.get_lua_files_recursively(path)
  local m = {}
  for _, file in ipairs(all_lua_files) do
    load_and_merge(file, attr, m)
  end
  return sort_table_recursive(m)
end

--- Main public interface: loads and merges modules from directory
--- Scans specified directory recursively for Lua files, loads them,
--- extracts specified attribute from each, and returns merged sorted table
--- @param dir string The directory path to load from
--- @param attr string The table key to extract from each module
--- @return table Merged result of all specified attributes
function M.load_from_directory(dir, attr)
  return merge_tables_from_directories(dir, attr)
end

--- just concatenates lists from all Lua files
--- @param dir string Directory to scan
--- @param attr string The attribute to extract (must be a list/array)
--- @return table Concatenated list
function M.concat_lists_from_dir(dir, attr)
  local result = {}

  -- Get all Lua files (using your existing function)
  local files = M.get_lua_files_recursively(dir)

  for _, file in ipairs(files) do
    local ok, mod = pcall(dofile, file)
    if ok and type(mod) == "table" and mod[attr] and type(mod[attr]) == "table" then
      -- Simple concatenation (no nested handling)
      for _, item in ipairs(mod[attr]) do
        table.insert(result, item)
      end
    end
  end

  return result
end

--- Calculates the relative module path from Neovim's config directory
--- Converts absolute file paths to Lua module-style relative paths
--- @param path string The absolute path to a Lua file (e.g., "/home/user/.config/nvim/lua/modules/init.lua")
--- @return string|nil The relative module path (e.g., "modules.init") or nil if path is outside config
--- @usage local mod_path = relative_path("/home/user/.config/nvim/lua/modules/init.lua") --> "modules.init"
function M.relative_path(path)
  local config_dir = vim.fn.stdpath("config")
  local lua_dir = config_dir .. "/lua/"

  -- Normalize paths for cross-platform compatibility
  path = path:gsub("\\", "/")
  config_dir = config_dir:gsub("\\", "/")
  lua_dir = lua_dir:gsub("\\", "/")

  -- Verify the path is within the config directory
  if not path:find(config_dir, 1, true) then
    vim.notify("Path is outside Neovim config directory: " .. path, vim.log.levels.WARN)
    return nil
  end

  -- Extract the portion after /lua/ directory
  local relative_path = path:match(".*/lua/(.+)%.lua$")
  if not relative_path then
    vim.notify("Path is not a Lua file in the expected location: " .. path, vim.log.levels.WARN)
    return nil
  end

  -- Convert filesystem path to Lua module notation
  relative_path = relative_path:gsub("/", ".")

  -- Special case: convert init.lua to parent directory name
  if relative_path:match("init$") then
    relative_path = relative_path:gsub("%.init$", "")
  end

  -- Normalize consecutive dots to single dot
  relative_path = relative_path:gsub("%.%.+", ".")


  return relative_path
end

M.get_dir = function(path)
  -- if path is a file
  if path:match("%.lua$") then
    return path:match("(.*/)")
    -- elif path is a dir
  elseif path:match("/$") then
    return path
  else
    return path .. "/"
  end
end

return M
