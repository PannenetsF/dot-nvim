--- quickfix function
--- @module autocommands.quickfix

local M = {}

-- Quickfix window mapping
local function setup_quickfix_mappings()
	vim.keymap.set("n", "q", ":cclose<CR> :lclose<CR>", { buffer = true })
end

M.setup_autocmd = function()
	vim.cmd([[
        function! QuickFixToggle()
          if empty(filter(getwininfo(), 'v:val.quickfix'))
            copen
          else
            cclose
          endif
        endfunction
      ]])
	vim.api.nvim_create_augroup("QuickFixMapping", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = "QuickFixMapping",
		pattern = "qf",
		callback = setup_quickfix_mappings,
	})
end

return M
