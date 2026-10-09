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
		-- Load at startup: the <Space> trigger is a buffer-local mapping that
		-- only exists after setup. With VeryLazy, pressing leader during the
		-- first ~tens of ms after opening a file hits the default Space mapping
		-- (cursor right) and silently breaks the leader sequence.
		lazy = false,
		cmd = "WhichKey",
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
