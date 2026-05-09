--- Guard built-in Treesitter startup for large files and stale parsers.
--- @module vimconf.treesitter-guard

local M = {}

local notified = {}

local function notify_once(key, msg)
	if notified[key] then
		return
	end
	notified[key] = true
	vim.notify(msg, vim.log.levels.WARN)
end

M.conf = function()
	if vim.g.dotnvim_treesitter_guard_loaded then
		return
	end
	vim.g.dotnvim_treesitter_guard_loaded = true

	local original_start = vim.treesitter.start
	vim.treesitter.start = function(bufnr, lang)
		if bufnr == nil or bufnr == 0 then
			bufnr = vim.api.nvim_get_current_buf()
		end
		if vim.b[bufnr].dotnvim_large_file then
			return
		end

		local ok, result = pcall(original_start, bufnr, lang)
		if ok then
			return result
		end

		vim.b[bufnr].dotnvim_treesitter_failed = true
		local ft = vim.bo[bufnr].filetype
		notify_once(
			ft ~= "" and ft or "unknown",
			string.format("Treesitter disabled for %s: %s", ft ~= "" and ft or "this buffer", result)
		)
	end
end

return M
