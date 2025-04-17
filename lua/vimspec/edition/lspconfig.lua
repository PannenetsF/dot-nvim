local M = {}

local fn = vim.fn
local diagnostic = vim.diagnostic
local api = vim.api
local lsp = vim.lsp

local utils = require("utils.functions")
local set_qflist = function(buf_num, severity)
    local diagnostics = nil
    diagnostics = vim.diagnostic.get(buf_num, { severity = severity })

    local qf_items = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist({}, " ", { title = "Diagnostics", items = qf_items })

    -- open quickfix by default
    vim.cmd([[copen]])
end
M.custom_attach = function(client, bufnr)
    api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local float_opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "rounded",
                source = "always", -- show source in diagnostic popup window
                prefix = " ",
            }

            if not vim.b.diagnostics_pos then
                vim.b.diagnostics_pos = { nil, nil }
            end

            local cursor_pos = api.nvim_win_get_cursor(0)
            if
                (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
                and #diagnostic.get() > 0
            then
                diagnostic.open_float(nil, float_opts)
            end

            vim.b.diagnostics_pos = cursor_pos
        end,
    })

    -- The blow command will highlight the current variable and its usages in the buffer.
    if client.server_capabilities.documentHighlightProvider then
        vim.cmd([[
      hi! link LspReferenceRead Visual
      hi! link LspReferenceText Visual
      hi! link LspReferenceWrite Visual
    ]])

        local gid = api.nvim_create_augroup("lsp_document_highlight", { clear = true })
        api.nvim_create_autocmd("CursorHold", {
            group = gid,
            buffer = bufnr,
            callback = function()
                lsp.buf.document_highlight()
            end,
        })

        api.nvim_create_autocmd("CursorMoved", {
            group = gid,
            buffer = bufnr,
            callback = function()
                lsp.buf.clear_references()
            end,
        })
    end

    if vim.g.logging_level == "debug" then
        local msg = string.format("Language server %s started!", client.name)
        vim.notify(msg, vim.log.levels.DEBUG, { title = "Nvim-config" })
    end
end

M.sparse_key_map = {
    { "gd",        vim.lsp.buf.definition,     desc = "go to definition" },
    { "K",         vim.lsp.buf.hover },
    { "gk",        vim.lsp.buf.signature_help, desc = "open signature_help" },
    { "<space>rn", vim.lsp.buf.rename,         desc = "varialbe rename" },
    { "gr",        vim.lsp.buf.references,     desc = "show references" },
    { "[d",        diagnostic.goto_prev,       desc = "previous diagnostic" },
    { "]d",        diagnostic.goto_next,       desc = "next diagnostic" },
    { "<space>qw", diagnostic.setqflist,       desc = "put window diagnostics to qf" },
    {
        "<space>qb",
        function()
            set_qflist(bufnr)
        end,
        desc = "put buffer diagnostics to qf"
    },
    { "<space>wa", vim.lsp.buf.add_workspace_folder,    desc = "add workspace folder" },
    { "<space>wr", vim.lsp.buf.remove_workspace_folder, desc = "remove workspace folder" },
    {
        "<space>wl",
        function()
            vim.inspect(vim.lsp.buf.list_workspace_folders())
        end,
        desc = "list workspace folder"
    },
    { "<space>l", vim.lsp.buf.format, desc = "format code" },
}

M.setup = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")
    if utils.executable("pylsp") then
        local venv_path = os.getenv("VIRTUAL_ENV")
        local py_path = nil
        -- decide which python executable to use for mypy
        if venv_path ~= nil then
            py_path = venv_path .. "/bin/python3"
        else
            py_path = vim.g.python3_host_prog
        end

        print('setting up pylsp with python executable: ')
        lspconfig.pylsp.setup({
            on_attach = M.custom_attach,
            settings = {
                pylsp = {
                    plugins = {
                        -- formatter options
                        black = { enabled = true },
                        autopep8 = { enabled = false },
                        yapf = { enabled = false },
                        -- linter options
                        pylint = { enabled = false, executable = "pylint" },
                        ruff = { enabled = false },
                        pyflakes = { enabled = false },
                        pycodestyle = { enabled = false },
                        -- type checker
                        pylsp_mypy = {
                            enabled = true,
                            -- overrides = { "--python-executable", py_path, true },
                            report_progress = true,
                            live_mode = false,
                        },
                        -- auto-completion options
                        jedi_completion = { fuzzy = true },
                        -- import sorting
                        isort = { enabled = true },
                    },
                },
            },
            flags = {
                debounce_text_changes = 200,
            },
            capabilities = capabilities,
        })
    else
        vim.notify("pylsp not found!", vim.log.levels.WARN, { title = "Nvim-config" })
    end

    if utils.executable("pyright") then
        print('setting up pyright with python executable: ')
        lspconfig.pyright.setup({
            on_attach = M.custom_attach,
            capabilities = capabilities,
        })
    else
        vim.notify("pyright not found!", vim.log.levels.WARN, { title = "Nvim-config" })
    end

    if utils.executable("ltex-ls") then
        lspconfig.ltex.setup({
            on_attach = M.custom_attach,
            cmd = { "ltex-ls" },
            filetypes = { "text", "plaintex", "tex", "markdown" },
            settings = {
                ltex = {
                    language = "en",
                },
            },
            flags = { debounce_text_changes = 300 },
        })
    end

    if utils.executable("clangd") then
        lspconfig.clangd.setup({
            on_attach = M.custom_attach,
            capabilities = capabilities,
            filetypes = {
                "c",
                "cpp",
                "objc",
                "objcpp",
                "cuda",
                "proto",
            },
            flags = {
                debounce_text_changes = 500,
            },
        })
    end

    -- set up vim-language-server
    if utils.executable("vim-language-server") then
        lspconfig.vimls.setup({
            on_attach = M.custom_attach,
            flags = {
                debounce_text_changes = 500,
            },
            capabilities = capabilities,
        })
    else
        vim.notify("vim-language-server not found!", vim.log.levels.WARN, { title = "Nvim-config" })
    end

    -- set up bash-language-server
    if utils.executable("bash-language-server") then
        lspconfig.bashls.setup({
            on_attach = M.custom_attach,
            capabilities = capabilities,
        })
    end

    if utils.executable("lua-language-server") then
        -- settings for lua-language-server can be found on https://github.com/LuaLS/lua-language-server/wiki/Settings .
        lspconfig.lua_ls.setup({
            on_attach = M.custom_attach,
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                        version = "LuaJIT",
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { "vim" },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files,
                        -- see also https://github.com/LuaLS/lua-language-server/wiki/Libraries#link-to-workspace .
                        -- Lua-dev.nvim also has similar settings for lua ls, https://github.com/folke/neodev.nvim/blob/main/lua/neodev/luals.lua .
                        library = {
                            fn.stdpath("data") .. "/lazy/emmylua-nvim",
                            fn.stdpath("config"),
                        },
                        maxPreload = 2000,
                        preloadFileSize = 50000,
                    },
                },
            },
            capabilities = capabilities,
        })
    end

    -- Change diagnostic signs.
    fn.sign_define("DiagnosticSignError", { text = "🆇", texthl = "DiagnosticSignError" })
    fn.sign_define("DiagnosticSignWarn", { text = "⚠️", texthl = "DiagnosticSignWarn" })
    fn.sign_define("DiagnosticSignInfo", { text = "ℹ️", texthl = "DiagnosticSignInfo" })
    fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

    -- global config for diagnostic
    diagnostic.config({
        underline = false,
        virtual_text = false,
        signs = true,
        severity_sort = true,
    })

    -- lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
    --   underline = false,
    --   virtual_text = false,
    --   signs = true,
    --   update_in_insert = false,
    -- })

    -- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
    lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
    })
end


M.spec = function()
    return {
        "neovim/nvim-lspconfig",
        event = { "BufRead", "BufNewFile" },
        dependencies = {
            { "jose-elias-alvarez/null-ls.nvim" },
            { "folke/trouble.nvim" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "williamboman/mason-lspconfig.nvim" },
            {
                "williamboman/mason.nvim",
                build = function()
                    pcall(vim.cmd, "MasonUpdate")
                end,
            },
            { "jay-babu/mason-null-ls.nvim" },
        },

    }
end

return M
