--- setup lsp config for different languages
--- @module vimspec.edition.lspconfig

local M = {}

local fn = vim.fn
local diagnostic = vim.diagnostic
local api = vim.api
local lsp = vim.lsp

local utils = require("utils.functions")

--- set_qflist function
--- put the diagnostics of the current buffer to quickfix list
local set_qflist = function(buf_num, severity)
	local diagnostics = nil
	diagnostics = vim.diagnostic.get(buf_num, { severity = severity })

	local qf_items = vim.diagnostic.toqflist(diagnostics)
	vim.fn.setqflist({}, " ", { title = "Diagnostics", items = qf_items })

	-- open quickfix by default
	vim.cmd([[copen]])
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_buf_conf", { clear = true }),
	callback = function(event_context)
		local client = vim.lsp.get_client_by_id(event_context.data.client_id)
		-- vim.print(client.name, client.server_capabilities)

		if not client then
			return
		end

		local bufnr = event_context.buf

		-- Disable ruff hover feature in favor of Pyright
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end

		-- Uncomment code below to enable inlay hint from language server, some LSP server supports inlay hint,
		-- but disable this feature by default, so you may need to enable inlay hint in the LSP server config.
		-- vim.lsp.inlay_hint.enable(true, {buffer=bufnr})

		-- The blow command will highlight the current variable and its usages in the buffer.
		if client.server_capabilities.documentHighlightProvider then
			local gid = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
			vim.api.nvim_create_autocmd("CursorHold", {
				group = gid,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.document_highlight()
				end,
			})

			vim.api.nvim_create_autocmd("CursorMoved", {
				group = gid,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.clear_references()
				end,
			})
		end
	end,
	nested = true,
	desc = "Configure buffer keymap and behavior based on LSP",
})

--- define the lsp-related keymaps
M.sparse_key_map = {
	{
		"gd",
		function()
			vim.lsp.buf.definition({
				on_list = function(options)
					-- custom logic to avoid showing multiple definition when you use this style of code:
					-- `local M.my_fn_name = function() ... end`.
					-- See also post here: https://www.reddit.com/r/neovim/comments/19cvgtp/any_way_to_remove_redundant_definition_in_lua_file/

					-- vim.print(options.items)
					local unique_defs = {}
					local def_loc_hash = {}

					-- each item in options.items contain the location info for a definition provided by LSP server
					for _, def_location in pairs(options.items) do
						-- use filename and line number to uniquelly indentify a definition,
						-- we do not expect/want multiple definition in single line!
						local hash_key = def_location.filename .. def_location.lnum

						if not def_loc_hash[hash_key] then
							def_loc_hash[hash_key] = true
							table.insert(unique_defs, def_location)
						end
					end

					options.items = unique_defs

					-- set the location list
					---@diagnostic disable-next-line: param-type-mismatch
					vim.fn.setloclist(0, {}, " ", options)

					-- open the location list when we have more than 1 definitions found,
					-- otherwise, jump directly to the definition
					if #options.items > 1 then
						vim.cmd.lopen()
					else
						vim.cmd([[silent! lfirst]])
					end
				end,
			})
		end,
		desc = "go to definition",
	},
	{ "K", vim.lsp.buf.hover },
	{ "gk", vim.lsp.buf.signature_help, desc = "open signature_help" },
	{ "<space>rn", vim.lsp.buf.rename, desc = "varialbe rename" },
	{ "gr", vim.lsp.buf.references, desc = "show references" },
	{ "[d", diagnostic.goto_prev, desc = "previous diagnostic" },
	{ "]d", diagnostic.goto_next, desc = "next diagnostic" },
	{ "<space>qw", diagnostic.setqflist, desc = "put window diagnostics to qf" },
	{
		"<space>qb",
		function()
			set_qflist(bufnr)
		end,
		desc = "put buffer diagnostics to qf",
	},
	{ "<space>wa", vim.lsp.buf.add_workspace_folder, desc = "add workspace folder" },
	{ "<space>wr", vim.lsp.buf.remove_workspace_folder, desc = "remove workspace folder" },
	{
		"<space>wl",
		function()
			vim.inspect(vim.lsp.buf.list_workspace_folders())
		end,
		desc = "list workspace folder",
	},
	{ "<space>l", vim.lsp.buf.format, desc = "format code" },
}

--- setup lsp for different lang servers
--- for python, pylsp is preferred over pyright
--- for c/cpp, clangd is used
--- for bash, bash-language-server is used
--- for lua, lua-language-server is used
--- for latex, ltex is used (but in fact, there is of no uses)
--- for vim, vim-language-server is used
M.setup = function()
	require("mason").setup()
	require("mason-lspconfig").setup()

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	vim.lsp.config("*", {
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 500,
		},
	})

	-- A mapping from lsp server name to the executable name
	local enabled_lsp_servers = {
		pyright = "pyright",
		ruff = "ruff",
		lua_ls = "lua-language-server",
		ltex = "ltex-ls",
		clangd = "clangd",
		vimls = "vim-language-server",
		bashls = "bash-language-server",
		yamlls = "yaml-language-server",
	}

	for server_name, lsp_executable in pairs(enabled_lsp_servers) do
		if utils.executable(lsp_executable) then
			vim.lsp.enable(server_name)
		else
			local msg = string.format(
				"Executable '%s' for server '%s' not found! Server will not be enabled",
				lsp_executable,
				server_name
			)
			vim.notify(msg, vim.log.levels.WARN, { title = "Nvim-config" })
		end
	end
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
