--- Large file handling (10MB threshold)
--- if the file size is larger than 10MB, disable certain features
--- like relative number, swapfile, and undo levels
--- and set the buffer type to "nowrite"
--- if the file size is less than 10MB, enable those features
--- @module autocommands.largefile
local large_file_size = 10485760 -- 10MB

local function handle_large_file()
    local f = vim.fn.expand("<afile>")
    local file_size = vim.fn.getfsize(f)

    if file_size > large_file_size or file_size == -2 then
        vim.opt.eventignore:append("all")
        vim.opt.relativenumber = false
        vim.opt_local.swapfile = false
        vim.opt_local.bufhidden = "unload"
        vim.opt_local.buftype = "nowrite"
        vim.opt_local.undolevels = -1
    else
        vim.opt.eventignore:remove("all")
        vim.opt.relativenumber = true
    end
end

-- Quickfix window mapping
local function setup_quickfix_mappings()
    vim.keymap.set("n", "q", ":cclose<CR>", { buffer = true })
end

local M = {}

M.setup_autocmd = function()
    -- Set up autocommands
    vim.api.nvim_create_augroup("LargeFile", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPre", {
        group = "LargeFile",
        callback = handle_large_file,
    })

    vim.api.nvim_create_augroup("QuickFixMapping", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = "QuickFixMapping",
        pattern = "qf",
        callback = setup_quickfix_mappings,
    })
end

return M
