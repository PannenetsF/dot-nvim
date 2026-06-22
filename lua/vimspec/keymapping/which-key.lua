--- WhichKey group labels.
--- @module vimspec.keymapping.which-key

local M = {}
local utils = require("utils.loader")

local function get_groups()
	return utils.concat_lists_from_dir(vim.fn.stdpath("config") .. "/lua/vimspec/", "which_key_groups")
end

M.setup = function(opts)
	require("which-key").setup(opts or {})
end

M.spec = function()
	return {
		"folke/which-key.nvim",
		cmd = "WhichKey",
		event = "VeryLazy",
		opts = function()
			return {
				spec = get_groups(),
				triggers = {
					{ "<auto>", mode = "nxso" },
					{ "m", mode = "n" },
				},
			}
		end,
		config = function(_, opts)
			M.setup(opts)
		end,
	}
end

return M
