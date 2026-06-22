--- This module provides configuration and key mappings for the bufferline.nvim plugin.
--- @module vimspec.edition.bufferline

--- Configuration options for bufferline.nvim
local opts = {
	options = {
		numbers = "buffer_id",
		close_command = "bdelete! %d",
		right_mouse_command = nil,
		left_mouse_command = "buffer %d",
		middle_mouse_command = nil,
		indicator = {
			icon = "▎", -- this should be omitted if indicator style is not 'icon'
			style = "icon",
		},
		buffer_close_icon = "",
		color_icons = true,
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",
		max_name_length = 18,
		max_prefix_length = 15,
		tab_size = 10,
		diagnostics = false,
		custom_filter = function(bufnr)
			-- if the result is false, this buffer will be shown, otherwise, this
			-- buffer will be hidden.

			-- filter out filetypes you don't want to see
			local exclude_ft = { "qf", "fugitive", "git" }
			local cur_ft = vim.bo[bufnr].filetype
			local should_filter = vim.tbl_contains(exclude_ft, cur_ft)

			if should_filter then
				return false
			end

			return true
		end,
		show_buffer_icons = true,
		show_buffer_close_icons = true,
		show_close_icon = true,
		show_tab_indicators = true,
		persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
		separator_style = "bar",
		enforce_regular_tabs = false,
		always_show_bufferline = true,
		sort_by = "id",
	},
}

local M = {}

M.which_key_groups = {
	{ "<leader>b", group = "Buffers", mode = "n" },
	{ "<leader>b\\", group = "Split Buffer", mode = "n" },
}

local hl = {
	background = {
		italic = true,
	},
	buffer_selected = {
		bold = true,
	},
}

M.setup = function()
	require("scope").setup({})
	require("bufferline").setup({
		options = opts,
		highlights = hl,
	})
end

function _G.split_right()
	vim.cmd("vsplit")
	vim.cmd("wincmd l")
	vim.cmd("b #")
end

-- 向左分割并将当前 buffer 复制到新窗口
function _G.split_left()
	vim.cmd("vsplit")
	vim.cmd("wincmd h")
	vim.cmd("b #")
end

function _G.toggle_wrap()
	vim.cmd("lua vim.opt.wrap = not vim.opt.wrap")
end

M.spec = function()
	return {
		"akinsho/bufferline.nvim",
		event = { "BufEnter" },
		keys = {
			{ "<leader>c", "<cmd>BufferKill<CR>", desc = "Close Buffer", mode = "n" },
			{ "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Jump", mode = "n" },
			{ "<leader>bb", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous", mode = "n" },
			{ "<leader>bn", "<cmd>BufferLineCycleNext<cr>", desc = "Next", mode = "n" },
			{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer", mode = "n" },
			{
				"<leader>bt",
				'<cmd>lua require("snacks").scratch({ filekey = { cwd = false, branch = false } })<CR>',
				desc = "Global Scratch Buffer",
				mode = "n",
			},
			{ "<leader>bT", '<cmd>lua require("snacks").scratch()<CR>', desc = "Project Scratch Buffer", mode = "n" },
			{ "<leader>bC", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers", mode = "n" },
			{ "<leader>be", "<cmd>BufferLinePickClose<cr>", desc = "Pick which buffer to close", mode = "n" },
			{ "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all to the left", mode = "n" },
			{ "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all to the right", mode = "n" },
			{ "<leader>bd", "<cmd>windo diffthis<cr>", desc = "Open diff with current buffer", mode = "n" },
			{ "<leader>bD", "<cmd>windo diffoff<cr>", desc = "Close diff", mode = "n" },
			{ "<leader>bL", "<cmd>BufferLineSortByExtension<cr>", desc = "Sort by language", mode = "n" },
			{ "<leader>b\\l", "<cmd>lua split_left()<cr>", desc = "Split buffer to left", mode = "n" },
			{ "<leader>b\\r", "<cmd>lua split_right()<cr>", desc = "Split buffer to right", mode = "n" },
			{
				"<leader>bz",
				"<cmd>lua vim.opt.wrap = not vim.opt.wrap:get()<cr>",
				desc = "Toggle Wrap",
				mode = "n",
			},
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"tiagovla/scope.nvim",
		},
		config = function()
			M.setup()
		end,
	}
end
return M
