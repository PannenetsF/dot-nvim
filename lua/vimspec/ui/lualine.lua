--- This module provides configuration lualine.nvim plugin.
--- @module vimspec.edition.lualine

local fn = vim.fn

local M = {}
M.setup = function()
	local git = require("utils.icons").git
	local function spell()
		if vim.o.spell then
			return string.format("[SPELL]")
		end

		return ""
	end

	local window_width_limit = 100
	local hide_in_width = function()
		return vim.o.columns > window_width_limit
	end

	--- show indicator for Chinese IME
	local function ime_state()
		if vim.g.is_mac then
			-- ref: https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions/xkblayout.vim#L11
			local layout = fn.libcall(vim.g.XkbSwitchLib, "Xkb_Switch_getXkbLayout", "")

			-- We can use `xkbswitch -g` on the command line to get current mode.
			-- mode for macOS builtin pinyin IME: com.apple.inputmethod.SCIM.ITABC
			-- mode for Rime: im.rime.inputmethod.Squirrel.Rime
			local res = fn.match(layout, [[\v(Squirrel\.Rime|SCIM.ITABC)]])
			if res ~= -1 then
				return "[CN]"
			end
		end

		return ""
	end

	local function trailing_space()
		if not vim.o.modifiable then
			return ""
		end

		local line_num = nil

		for i = 1, fn.line("$") do
			local linetext = fn.getline(i)
			-- To prevent invalid escape error, we wrap the regex string with `[[]]`.
			local idx = fn.match(linetext, [[\v\s+$]])

			if idx ~= -1 then
				line_num = i
				break
			end
		end

		local msg = ""
		if line_num ~= nil then
			msg = string.format("[%d]trailing", line_num)
		end

		return msg
	end

	local function mixed_indent()
		if not vim.o.modifiable then
			return ""
		end

		local space_pat = [[\v^ +]]
		local tab_pat = [[\v^\t+]]
		local space_indent = fn.search(space_pat, "nwc")
		local tab_indent = fn.search(tab_pat, "nwc")
		local mixed = (space_indent > 0 and tab_indent > 0)
		local mixed_same_line
		if not mixed then
			mixed_same_line = fn.search([[\v^(\t+ | +\t)]], "nwc")
			mixed = mixed_same_line > 0
		end
		if not mixed then
			return ""
		end
		if mixed_same_line ~= nil and mixed_same_line > 0 then
			return "MI:" .. mixed_same_line
		end
		local space_indent_cnt = fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
		local tab_indent_cnt = fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
		if space_indent_cnt > tab_indent_cnt then
			return "MI:" .. tab_indent
		else
			return "MI:" .. space_indent
		end
	end

	local diff = function()
		local git_status = vim.b.gitsigns_status_dict
		if git_status == nil then
			return
		end

		local modify_num = git_status.changed
		local remove_num = git_status.removed
		local add_num = git_status.added

		local info = { added = add_num, modified = modify_num, removed = remove_num }
		-- vim.print(info)
		return info
	end

	local virtual_env = function()
		-- only show virtual env for Python
		if vim.bo.filetype ~= "python" then
			return ""
		end

		local conda_env = os.getenv("CONDA_DEFAULT_ENV")
		local venv_path = os.getenv("VIRTUAL_ENV")

		if venv_path == nil then
			if conda_env == nil then
				return ""
			else
				return string.format("  %s (conda)", conda_env)
			end
		else
			local venv_name = vim.fn.fnamemodify(venv_path, ":t")
			return string.format("  %s (venv)", venv_name)
		end
	end

	local opts = {
		options = {
			icons_enabled = true,
			theme = "auto",
			-- component_separators = { left = "", right = "" },
			-- section_separators = { left = "", right = "" },
			section_separators = "",
			component_separators = "",
			disabled_filetypes = {},
			always_divide_middle = true,
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				"branch",
				{
					"diff",
					source = diff,
				},
				{
					virtual_env,
					color = { fg = "black", bg = "#F1CA81" },
				},
			},
			lualine_c = {
				"filename",
				{
					ime_state,
					color = { fg = "black", bg = "#f46868" },
				},
				{
					spell,
					color = { fg = "black", bg = "#a7c080" },
				},
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = { error = "🆇 ", warn = "⚠️ ", info = "ℹ️ ", hint = " " },
				},
				-- {
				-- 	"navic",
				-- 	color_correction = "static",
				-- 	navic_opts = { highlight = true },
				-- },
				-- {
				-- 	function()
				-- 		return navic.get_location()
				-- 	end,
				-- 	cond = function()
				-- 		return navic.is_available()
				-- 	end,
				-- },
			},
			lualine_x = {
				"encoding",
				{
					"fileformat",
					symbols = {
						unix = "unix",
						dos = "win",
						mac = "mac",
					},
				},
				"filetype",
				{
					require("noice").api.statusline.mode.get,
					cond = require("noice").api.statusline.mode.has,
					color = { fg = "#ff9e64" },
				},
			},
			lualine_y = {
				"location",
				{
					function()
						local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
						if #buf_clients == 0 then
							return "LSP Inactive"
						end

						local buf_ft = vim.bo.filetype
						local buf_client_names = {}
						local copilot_active = false
						local codeverse_active = false

						-- add client
						for _, client in pairs(buf_clients) do
							if client.name ~= "null-ls" and client.name ~= "copilot" and client.name ~= "codeverse" then
								table.insert(buf_client_names, client.name)
							end

							if client.name == "copilot" then
								copilot_active = true
							end
							if client.name == "codeverse" then
								codeverse_active = true
							end
						end

						local unique_client_names = table.concat(buf_client_names, ", ")
						local language_servers = string.format("[%s]", unique_client_names)

						if copilot_active then
							language_servers = language_servers .. "%#SLCopilot#" .. " " .. git.Octoface .. "%*"
						end
						if codeverse_active then
							language_servers = language_servers .. "%#SLCodeverse#" .. " " .. git.Codeverse .. "%*"
						end

						return language_servers
					end,
					color = { gui = "bold" },
					cond = hide_in_width,
				},
			},
			lualine_z = {
				{
					trailing_space,
					color = "WarningMsg",
				},
				{
					mixed_indent,
					color = "WarningMsg",
				},
				{
					"progress",
					fmt = function()
						return "%P/%L"
					end,
					color = {},
				},
			},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		extensions = { "quickfix", "fugitive", "nvim-tree", "toggleterm" },
	}
	require("lualine").setup(opts)
end

M.spec = function()
	return {
		"nvim-lualine/lualine.nvim",
		dependencies = { "folke/noice.nvim" },
		event = "VeryLazy",
		cond = require("utils.functions").firenvim_not_active,
	}
end
return M
