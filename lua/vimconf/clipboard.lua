--- setup clipboard with OSC52
--- @module vimconf.clipboard

local utils = require("utils.functions")
local M = {}
local clipboard_group = vim.api.nvim_create_augroup("dotnvim_clipboard", { clear = true })

local function paste()
	return {
		vim.fn.split(vim.fn.getreg(""), "\n"),
		vim.fn.getregtype(""),
	}
end

local function copy(reg)
	return function(lines)
		utils.copy_to_clipboard(lines, reg)
	end
end

M.load_clipboard = function()
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = copy("+"),
			["*"] = copy("*"),
		},

		paste = {
			["+"] = paste,
			["*"] = paste,
		},
	}

	vim.api.nvim_create_user_command("TmuxClipboardStatus", function()
		if utils.envvar("TMUX") == nil or not utils.executable("tmux") then
			vim.notify("当前不在 tmux 中", vim.log.levels.INFO)
			return
		end

		local set_clipboard = vim.trim(vim.fn.system({ "tmux", "show", "-sv", "set-clipboard" }))
		local allow_passthrough = vim.trim(vim.fn.system({ "tmux", "show", "-gv", "allow-passthrough" }))
		vim.notify(
			string.format("tmux set-clipboard=%s, allow-passthrough=%s", set_clipboard, allow_passthrough),
			vim.log.levels.INFO
		)
	end, { force = true })

	vim.api.nvim_create_autocmd("TextYankPost", {
		group = clipboard_group,
		callback = function()
			vim.highlight.on_yank()
		end,
	})
end

M.conf = function()
	M.load_clipboard()
end

return M
