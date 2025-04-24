--- load im-select, for zh-en co-edition
--- @module vimspec.edition.im-select
local M = {}

M.setup = function()
	local im_select = require("im_select")
	im_select.setup()
end

M.spec = function()
	return {
		"keaising/im-select.nvim",
	}
end

return M
