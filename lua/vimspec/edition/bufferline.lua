-- This module provides configuration and key mappings for the bufferline.nvim plugin.
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

--- add mapping in normal mode 
M.normal_key_map = {
	["c"] = { "<cmd>BufferKill<CR>", "Close Buffer" },
	b = {
		name = "Buffers",
		j = { "<cmd>BufferLinePick<cr>", "Jump" },
		f = { "<cmd>Telescope buffers previewer=false<cr>", "Find" },
		b = { "<cmd>BufferLineCyclePrev<cr>", "Previous" },
		n = { "<cmd>BufferLineCycleNext<cr>", "Next" },
		p = { "<cmd>BufferLineTogglePin<cr>", "Pin buffer" },
		C = { "<cmd>BufferLineCloseOthers<cr>", "Close other buffers" },
		e = {
			"<cmd>BufferLinePickClose<cr>",
			"Pick which buffer to close",
		},
		h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
		l = { "<cmd>BufferLineCloseRight<cr>", "Close all to the right" },
		D = {
			"<cmd>BufferLineSortByDirectory<cr>",
			"Sort by directory",
		},
		L = {
			"<cmd>BufferLineSortByExtension<cr>",
			"Sort by language",
		},
		["\\"] = {
			name = "Split Buffer",
			l = { "<cmd>lua split_left()<cr>", "Split buffer to left" },
			r = { "<cmd>lua split_right()<cr>", "Split buffer to right" },
		},
	},
}

M.setup = function()
	require("bufferline").setup(opts)
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

M.spec = function()
	return {
		"akinsho/bufferline.nvim",
		event = { "BufEnter" },
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			M.setup()
		end,
	}
end
return M
