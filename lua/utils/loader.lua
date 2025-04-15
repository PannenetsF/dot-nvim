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
--- @local
local function find_luas(path)
  if vim.fn.has("win32") == 1 then
    return io.popen('dir /s /b "'..path..'\\*.lua"')
  else
    return io.popen('find "'..path..'" -type f -name "*.lua"')
  end
end

--- Recursively collects all Lua files from a directory
--- @param path string The base directory path
--- @return table Array containing absolute paths of all found Lua files
--- @local
local function get_lua_files_recursively(path)
  local all_lua_files = {}
  local p = find_luas(path)
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
  local all_lua_files = get_lua_files_recursively(path)
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

return M