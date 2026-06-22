--- Codex helper keymaps.
--- @module vimconf.codex

local M = {}
local utils = require("utils.functions")

local function buffer_ref_path()
	local path = vim.fn.expand("%:p")
	if path == "" then
		return nil
	end

	return path
end

local function copy_ref(ref)
	vim.fn.setreg('"', ref)
	utils.copy_to_clipboard({ ref }, "+")
	vim.notify("Copied Codex ref: " .. ref, vim.log.levels.INFO)
end

local function copy_current_line_ref()
	local path = buffer_ref_path()
	if not path then
		vim.notify("No file path for current buffer", vim.log.levels.WARN)
		return
	end

	copy_ref(string.format("%s:%d", path, vim.fn.line(".")))
end

local function copy_visual_line_ref()
	local path = buffer_ref_path()
	if not path then
		vim.notify("No file path for current buffer", vim.log.levels.WARN)
		return
	end

	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	copy_ref(string.format("%s:%d-%d", path, start_line, end_line))
end

M.conf = function()
	vim.keymap.set("n", "<leader>yf", copy_current_line_ref, {
		silent = true,
		desc = "Copy Codex file ref",
	})

	vim.keymap.set("v", "<leader>yf", copy_visual_line_ref, {
		silent = true,
		desc = "Copy Codex file ref",
	})
end

return M
