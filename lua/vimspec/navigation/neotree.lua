--- Neo-tree configuration module for file system, git, buffer, and diagnostics navigation
--- Provides configuration, key mappings, and setup for neo-tree.nvim plugin
--- @module vimspec.navigation.neotree

local utils = require("utils.functions")
local M = {}
local CM = {} -- Component Module

--- Configures the display name component for nodes in neo-tree
-- Handles special formatting for directories, root nodes, and git status colors
-- @param config Table containing component configuration
-- @param node The tree node being rendered
-- @param state Current state of neo-tree
-- @return Table with text and highlight properties for the name component
function CM.name(config, node, state)
	local common = require("neo-tree.sources.common.components")
	local highlights = require("neo-tree.ui.highlights")

	local highlight = config.highlight or highlights.FILE_NAME
	local text = node.name
	if node.type == "directory" then
		highlight = highlights.DIRECTORY_NAME
		if config.trailing_slash and text ~= "/" then
			text = text .. "/"
		end
	end

	-- Special formatting for root nodes
	if node:get_depth() == 1 and node.type ~= "message" then
		highlight = highlights.ROOT_NAME
		text = vim.fn.fnamemodify(text, ":p:h:t")
		text = string.upper(text)
	else
		local filtered_by = common.filtered_by(config, node, state)
		highlight = filtered_by.highlight or highlight
		if config.use_git_status_colors then
			local git_status = state.components.git_status({}, node, state)
			if git_status and git_status.highlight then
				highlight = git_status.highlight
			end
		end
	end

	-- Add right padding if configured
	if type(config.right_padding) == "number" then
		if config.right_padding > 0 then
			text = text .. string.rep(" ", config.right_padding)
		end
	else
		text = text .. " "
	end

	return {
		text = text,
		highlight = highlight,
	}
end

--- Configures the icon component for nodes in neo-tree
-- Handles different icons for files, directories, and special cases
-- @param config Table containing component configuration
-- @param node The tree node being rendered
-- @param state Current state of neo-tree
-- @return Table with text and highlight properties for the icon component
function CM.icon(config, node, state)
	local common = require("neo-tree.sources.common.components")
	local highlights = require("neo-tree.ui.highlights")

	local icon = config.default or " "
	local highlight = config.highlight or highlights.FILE_ICON
	if node.type == "directory" then
		highlight = highlights.DIRECTORY_ICON
		if node.loaded and not node:has_children() then
			icon = not node.empty_expanded and config.folder_empty or config.folder_empty_open
		elseif node:is_expanded() then
			icon = config.folder_open or "-"
		else
			icon = config.folder_closed or "+"
		end
	elseif node.type == "file" or node.type == "terminal" then
		local success, web_devicons = pcall(require, "nvim-web-devicons")
		if success then
			local devicon, hl = web_devicons.get_icon(node.name, node.ext)
			icon = devicon or icon
			highlight = hl or highlight
		end
	end

	local filtered_by = common.filtered_by(config, node, state)

	-- Don't render icon in root folder
	if node:get_depth() == 1 then
		return {
			text = nil,
			highlight = highlight,
		}
	end

	return {
		text = icon .. " ",
		highlight = filtered_by.highlight or highlight,
	}
end

--- Main configuration table for neo-tree
-- Contains all settings for sources, window, filesystem, and components
local config = {
	close_if_last_window = true, -- Close Neo-tree if it's the last window
	sources = {
		"filesystem",
		"buffers",
		"git_status",
		"diagnostics",
	},

	--- Configuration for the source selector in the winbar
	source_selector = {
		winbar = true, -- Show selector in winbar
		content_layout = "center",
		tabs_layout = "equal",
		show_separator_on_edge = true,
		sources = {
			{ source = "filesystem", display_name = "󰉓" },
			{ source = "buffers", display_name = "󰈙" },
			{ source = "git_status", display_name = "" },
			{ source = "document_symbols", display_name = "o" },
			{ source = "diagnostics", display_name = "󰒡" },
		},
	},

	--- Default configurations for all components
	default_component_configs = {
		indent = {
			indent_size = 2,
			padding = 1, -- Left padding
			with_markers = true,
			indent_marker = "│",
			last_indent_marker = "└",
			with_expanders = true, -- Enable expanders for nested files
			expander_collapsed = "",
			expander_expanded = "",
			expander_highlight = "NeoTreeExpander",
		},
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "",
			folder_empty_open = "",
			default = " ", -- Fallback icon
		},
		modified = { symbol = "" },
	},

	--- Window configuration
	window = {
		width = 40,
		mappings = {
			["<tab>"] = "open",
			["l"] = "open",
			["<space>"] = "none",
			["P"] = { "toggle_preview", config = { use_float = true } },
		},
	},

	--- Filesystem specific configuration
	filesystem = {
		window = {
			mappings = {
				["H"] = "navigate_up",
				["<bs>"] = "toggle_hidden",
				["."] = "set_root",
				["/"] = "fuzzy_finder",
				["f"] = "filter_on_submit",
				["<c-x>"] = "clear_filter",
				["a"] = { "add", config = { show_path = "relative" } },
				["y"] = function(state)
					local node = state.tree:get_node()
					local filename = node.name
					vim.fn.setreg('"', filename)
					utils.copy_to_clipboard({ vim.fn.getreg('"') })
					vim.notify("Copied: " .. filename)
				end,
				["Y"] = function(state)
					local node = state.tree:get_node()
					local filepath = node:get_id()
					vim.fn.setreg('"', filepath)
					utils.copy_to_clipboard({ vim.fn.getreg('"') })
					vim.notify("Copied: " .. filepath)
				end,
			},
		},
		filtered_items = {
			hide_dotfiles = false,
			hide_gitignored = false,
		},
		follow_current_file = {
			enabled = true, -- Auto-focus current file when changed
		},
		group_empty_dirs = true, -- Group empty directories together
		components = CM, -- Use our custom components
	},
	async_directory_scan = "always", -- Always scan directories asynchronously
}

--- Hides cursor in neo-tree window for cleaner appearance
local function hideCursor()
	vim.cmd([[
    setlocal guicursor=n:block-Cursor
    setlocal foldcolumn=0
    hi Cursor blend=100
  ]])
end

--- Restores default cursor settings
local function showCursor()
	vim.cmd([[
    setlocal guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
    hi Cursor blend=0
  ]])
end

--- Creates an augroup for managing cursor visibility
-- @param group Name of the autocommand group
-- @return The created augroup ID
M.augroup = function(group)
	return vim.api.nvim_create_augroup(group, { clear = true })
end

-- Set up autocommands to manage cursor visibility in neo-tree
local neotree_group = M.augroup("neo-tree_hide_cursor")

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertEnter" }, {
	group = neotree_group,
	callback = function()
		local action = vim.bo.filetype == "neo-tree" and hideCursor or showCursor
		action()
	end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
	group = neotree_group,
	callback = function()
		showCursor()
	end,
})

--- Key mappings for neo-tree operations
M.normal_key_map = {
	["e"] = { "<cmd>Neotree toggle reveal<cr>", "Toggle Neotree" },
	s = {
		name = "Neotree",
		f = { "<cmd>Neotree filesystem<cr>", "Filesystem" },
		g = { "<cmd>Neotree git_status<cr>", "Git Status" },
		b = { "<cmd>Neotree buffers<cr>", "Buffers" },
		d = { "<cmd>Neotree diagnostics<cr>", "Diagnostics" },
	},
}

--- Sets up the neo-tree plugin with our configuration
M.setup = function()
	vim.g.neo_tree_remove_legacy_commands = 1
	require("neo-tree").setup(config)
end

--- Returns the plugin specification for lazy.nvim
-- @return Table with plugin specification
M.spec = function()
	return {
		"nvim-neo-tree/neo-tree.nvim",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		deactivate = function()
			vim.cmd([[Neotree close]])
		end,
	}
end

return M
