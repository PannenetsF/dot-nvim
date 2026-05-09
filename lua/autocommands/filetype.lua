--- Filetype fallback for buffers opened after an empty startup screen.
--- @module autocommands.filetype
local M = {}

local function detect_missing_filetype(ev)
	if vim.bo[ev.buf].filetype ~= "" then
		return
	end

	local filetype, on_detect = vim.filetype.match({
		filename = ev.file,
		buf = ev.buf,
	})
	if not filetype then
		return
	end

	if on_detect then
		on_detect(ev.buf)
	end

	vim.bo[ev.buf].filetype = filetype
end

M.setup_autocmd = function()
	vim.api.nvim_create_augroup("DotNvimFiletypeFallback", { clear = true })
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = "DotNvimFiletypeFallback",
		callback = detect_missing_filetype,
		desc = "Set filetype when the built-in detector missed a newly opened file",
	})
end

return M
