--- provide functions needed by nvim 
--- @module utils.functions
local fn = vim.fn

local M = {}


local is_mac = fn.has("mac") == 1 or fn.has("macunix") == 1
local is_linux = fn.has("unix") == 1 and not is_mac
local is_win = fn.has("win32") == 1 or fn.has("win64") == 1

if is_win then
    -- warn
    print("Windows is not supported")
end

M.platform = function()
    if is_mac then
        return "mac"
    elseif is_linux then
        return "linux"
    elseif is_win then
        return "win"
    else
        return "unknown"
    end
end

function M.executable(name)
    if fn.executable(name) > 0 then
        return true
    end

    return false
end

function M.envvar(name)
    local envtab = fn.environ()
    return envtab[name]
end

M.has = function(feat)
    if fn.has(feat) == 1 then
        return true
    end

    return false
end

local uv = vim.loop
local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"
M.join_paths = function(...)
    local result = table.concat({ ... }, path_sep)
    return result
end

M.get_cache_dir = function()
    return vim.call("stdpath", "cache")
end


--- Checks whether a given path exists and is a directory
function M.is_directory(path)
    local uv = vim.loop
    local stat = uv.fs_stat(path)
    return stat and stat.type == "directory" or false
end

M.find_shell = function()
    -- our order: zsh(with-ohz) bash sh
    -- if there is a zsh, need check env var ZSH
    local decision = nil
    if M.executable("zsh") and M.envvar("ZSH") then
        decision = "zsh"
    end
    if M.executable("bash") and decision == nil then
        decision = "bash"
    end
    if decision == nil then
        decision = "sh"
    end
    return decision
end

return M