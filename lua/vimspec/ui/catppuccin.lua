--- Load catppuccin theme 
--- @module vimspec.ui.catppuccin
local M = {}
M.spec = function()
    return {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        flavour = "auto", -- latte, frappe, macchiato, mocha
        background = {    -- :h background
            light = "latte",
            dark = "mocha",
        },
        opts = {
            term_colors = true,
            transparent_background = false,
            styles = {
                comments = {},
                conditionals = {},
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
            },
            color_overrides = {
                mocha = {
                    base = "#000000",
                    mantle = "#000000",
                    crust = "#000000",
                },
            },
            integrations = {
                telescope = {
                    enabled = true,
                    style = "nvchad",
                },
                dropbar = {
                    enabled = true,
                    color_mode = true,
                },
            },
        },
    }
end

return M
