--- Alpha-nvim configuration for splash screen 
--- @module vimspec.ui.alpha-nvim
local M = {}

local slogan = {
    [[████████ ██   ██ ██ ███    ██ ██   ██     ████████ ██     ██ ██  ██████ ███████ ]],
    [[   ██    ██   ██ ██ ████   ██ ██  ██         ██    ██     ██ ██ ██      ██      ]],
    [[   ██    ███████ ██ ██ ██  ██ █████          ██    ██  █  ██ ██ ██      █████   ]],
    [[   ██    ██   ██ ██ ██  ██ ██ ██  ██         ██    ██ ███ ██ ██ ██      ██      ]],
    [[   ██    ██   ██ ██ ██   ████ ██   ██        ██     ███ ███  ██  ██████ ███████ ]],
    [[                                                                                ]],
    [[                                                                                ]],
    [[      ██████  ██████  ██████  ███████      ██████  ███    ██  ██████ ███████    ]],
    [[     ██      ██    ██ ██   ██ ██          ██    ██ ████   ██ ██      ██         ]],
    [[     ██      ██    ██ ██   ██ █████       ██    ██ ██ ██  ██ ██      █████      ]],
    [[     ██      ██    ██ ██   ██ ██          ██    ██ ██  ██ ██ ██      ██         ]],
    [[      ██████  ██████  ██████  ███████      ██████  ██   ████  ██████ ███████    ]],
}

M.setup = function()
    local theta = require("alpha.themes.theta")
    theta.header.val = slogan
    require("alpha").setup(require("alpha.themes.theta").config)
end

M.spec = function()
    return {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    }
end

return M
