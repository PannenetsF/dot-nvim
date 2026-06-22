--- WhichKey group labels.
--- @module vimspec.keymapping.which-key

local M = {}
local utils = require("utils.loader")

M.setup = function()
	local groups = utils.concat_lists_from_dir(vim.fn.stdpath("config") .. "/lua/vimspec/", "which_key_groups")
	if #groups > 0 then
		require("which-key").add(groups)
	end
end

M.spec = function()
	return {
		"folke/which-key.nvim",
		cmd = "WhichKey",
		event = "VeryLazy",
		config = function()
			M.setup()
		end,
	}
end

return M
