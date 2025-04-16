--- telescope with fzf extended
--- @module vimspec.navigation.telescope-fzf
local M = {}

M.spec = function()
    return {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    }
end

return M