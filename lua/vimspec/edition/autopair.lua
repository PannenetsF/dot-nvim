--- autopairs after completion
--- @module vimspec.edition.autopair
local M = {}

M.setup = function()
    M.autopairs = {
        active = true,
        on_config_done = nil,
        ---@usage  modifies the function or method delimiter by filetypes
        map_char = {
            all = "(",
            tex = "{",
        },
        ---@usage check bracket in same line
        enable_check_bracket_line = false,
        ---@usage check treesitter
        check_ts = true,
        ts_config = {
            lua = { "string", "source" },
            javascript = { "string", "template_string" },
            java = false,
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
        enable_moveright = true,
        ---@usage disable when recording or executing a macro
        disable_in_macro = false,
        ---@usage add bracket pairs after quote
        enable_afterquote = true,
        ---@usage map the <BS> key
        map_bs = true,
        ---@usage map <c-w> to delete a pair if possible
        map_c_w = false,
        ---@usage disable when insert after visual block mode
        disable_in_visualblock = false,
        ---@usage  change default fast_wrap
        fast_wrap = {
            map = "<M-e>",
            chars = { "{", "[", "(", '"', "'" },
            pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
            offset = 0, -- Offset from pattern match
            end_key = "$",
            keys = "qwertyuiopzxcvbnmasdfghjkl",
            check_comma = true,
            highlight = "Search",
            highlight_grey = "Comment",
        },
    }
    local autopairs = require("nvim-autopairs")

    autopairs.setup({
        check_ts = M.autopairs.check_ts,
        enable_check_bracket_line = M.autopairs.enable_check_bracket_line,
        ts_config = M.autopairs.ts_config,
        disable_filetype = M.autopairs.disable_filetype,
        disable_in_macro = M.autopairs.disable_in_macro,
        ignored_next_char = M.autopairs.ignored_next_char,
        enable_moveright = M.autopairs.enable_moveright,
        enable_afterquote = M.autopairs.enable_afterquote,
        map_c_w = M.autopairs.map_c_w,
        map_bs = M.autopairs.map_bs,
        disable_in_visualblock = M.autopairs.disable_in_visualblock,
        fast_wrap = M.autopairs.fast_wrap,
    })

    if M.autopairs.on_config_done then
        M.autopairs.on_config_done(autopairs)
    end

    pcall(function()
        local function on_confirm_done(...)
            require("nvim-autopairs.completion.cmp").on_confirm_done()(...)
        end
        require("cmp").event:off("confirm_done", on_confirm_done)
        require("cmp").event:on("confirm_done", on_confirm_done)
    end)
end

M.spec = function()
    return {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        enabled = true,
        dependencies = { "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp" },
    }
end

return M
