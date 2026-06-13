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

local uv = vim.uv
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
	local uv = vim.uv
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

local tmux_clipboard_ready = false
local tmux_clipboard_pending = false

local function ensure_tmux_clipboard()
	if tmux_clipboard_ready or tmux_clipboard_pending then
		return true
	end
	if M.envvar("TMUX") == nil or not M.executable("tmux") then
		return false
	end

	tmux_clipboard_pending = true
	vim.system({ "tmux", "set", "-sq", "set-clipboard", "on" }, {}, function(result)
		tmux_clipboard_ready = result.code == 0
		tmux_clipboard_pending = false
	end)
	vim.system({ "tmux", "set", "-gq", "allow-passthrough", "on" })

	return true
end

M.copy_to_clipboard = function(reg, clipboard_reg)
	local content = reg or vim.v.event.regcontents
	local content_table = content
	if type(content) == "string" then
		content_table = { content }
	end
	if type(content) == "table" then
		content = table.concat(content, "\n")
	end
	content = tostring(content or "")

	local in_tmux = M.envvar("TMUX") ~= nil
	local is_empty = content == ""
	local is_remote = M.envvar("SSH_CONNECTION") ~= nil or M.envvar("SSH_TTY") ~= nil or M.envvar("SSH_CLIENT") ~= nil

	local function copy_system(str)
		if is_empty then
			return false
		end
		if M.platform() == "mac" and M.executable("pbcopy") then
			vim.system({ "pbcopy" }, { stdin = str })
			return true
		end
		if M.executable("wl-copy") then
			vim.system({ "wl-copy" }, { stdin = str })
			return true
		end
		if M.executable("xclip") then
			vim.system({ "xclip", "-selection", "clipboard" }, { stdin = str })
			return true
		end
		return false
	end

	if is_empty then
		return
	end

	if in_tmux then
		ensure_tmux_clipboard()
	end

	if not is_remote and copy_system(content) then
		if in_tmux and M.executable("tmux") then
			vim.system({ "tmux", "load-buffer", "-" }, { stdin = content })
		end
		return
	end

	if clipboard_reg == "+" or clipboard_reg == nil then
		local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
		copy_to_unnamedplus(content_table)
	end
	if clipboard_reg == "*" or clipboard_reg == nil then
		local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
		copy_to_unnamed(content_table)
	end

	if in_tmux and M.executable("tmux") then
		vim.system({ "tmux", "load-buffer", "-" }, { stdin = content })
	end
end

return M
