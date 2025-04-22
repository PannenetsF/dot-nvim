--- setup nvim-cmp for completion
--- @module vimspec.edition.nvim-cmp
local M = {}

M.setup = function()
	local cmp = require("cmp")
	local lspkind = require("lspkind")
	cmp.setup({
		snippet = {
			expand = function(args)
				-- For `ultisnips` user.
				vim.fn["UltiSnips#Anon"](args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert({
			["<Tab>"] = function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end,
			["<S-Tab>"] = function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end,
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<C-e>"] = cmp.mapping.abort(),
			["<Esc>"] = cmp.mapping.close(),
			["<C-d>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
		}),
		sources = {
			{ name = "nvim_lsp" }, -- For nvim-lsp
			{ name = "ultisnips" }, -- For ultisnips user.
			{ name = "path" }, -- for path completion
			{ name = "buffer", keyword_length = 2 }, -- for buffer word completion
			{
				name = "dictionary",
				keyword_length = 2,
			},
			{ name = "emoji", insert = true }, -- emoji completion
		},
		completion = {
			keyword_length = 1,
			completeopt = "menu,noselect",
		},
		view = {
			entries = "custom",
		},
		formatting = {
			format = lspkind.cmp_format({
				mode = "symbol_text",
				menu = {
					nvim_lsp = "[LSP]",
					ultisnips = "[US]",
					nvim_lua = "[Lua]",
					path = "[Path]",
					buffer = "[Buffer]",
					emoji = "[Emoji]",
					omni = "[Omni]",
					dictionary = "[Dict]",
					vimtex = "[TeX]",
				},
			}),
		},
	})

	cmp.setup.filetype("tex", {
		sources = {
			{ name = "vimtex" }, -- For ultisnips user.
			{ name = "path" }, -- For ultisnips user.
			{ name = "ultisnips" }, -- For ultisnips user.
			{ name = "buffer", keyword_length = 2 }, -- for buffer word completion
		},
	})
	-- add highlight groups for cmp
	--  see https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-add-visual-studio-code-dark-theme-colors-to-the-menu
	-- gray
	vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
	-- blue
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
	-- light blue
	vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
	vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
	vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
	-- pink
	vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
	vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
	-- front
	vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
	vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
	vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })

	-- for utilsnip
	vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" }
	vim.g.UltiSnipsExpandTrigger = "<Tab>"
	vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
	vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
	-- vim.g.UltiSnipsEnableSnipMate = 0  -- Disable SnipMate compatibility
	vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" } -- Only load snippets from UltiSnips directory
	vim.g.UltiSnipsEditSplit = "vertical" -- Use vertical split for editing snippets
	vim.g.UltiSnipsUsePythonVersion = 3 -- Ensure Python3 is used
end

M.spec = function()
	return {
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"onsails/lspkind-nvim",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-omni",
			"quangnguyen30192/cmp-nvim-ultisnips",
			"saadparwaiz1/cmp_luasnip",
			"micangl/cmp-vimtex",
		},
	}
end

return M
