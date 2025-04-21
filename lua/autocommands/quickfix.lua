--- quickfix function
--- @module autocommands.quickfix

local M = {}

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
end

return M
