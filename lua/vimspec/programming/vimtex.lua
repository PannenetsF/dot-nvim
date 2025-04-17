--- vimtex config
--- @module vimspec.programming.vimtex
local M = {}

local config_shared = function()
    vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-xelatex",
    }
    vim.g.vimtex_compiler_latexmk = {
        options = {
            "-pdf",
            "-verbose",
            "-file-line-error",
            "-synctex=1",
            "-interaction=nonstopmode",
            "--shell-escape",
        },
    }
    vim.g.tex_comment_nospell = 1
    vim.g.vimtex_compiler_progname = "nvr"
    vim.g.vimtex_quickfix_open_on_warning = 0
end

local config_linux = function()
    vim.g.vimtex_view_general_viewer = "zathura"
end

local config_mac = function()
    vim.g.vimtex_view_general_viewer = "skim"
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1
end

local config_platform = function()
    local platform = require("utils.functions").platform()
    if platform == "linux" then
        config_linux()
    elseif platform == "mac" then
        config_mac()
    end
end

M.setup = function()
    config_shared()
    config_platform()
end

M.spec = function()
    return {
        "lervag/vimtex",
        --- make lazy = true, to make sure the reverse search works
        lazy = true,
        opt = true,
        ft = "tex",
    }
end

return M
