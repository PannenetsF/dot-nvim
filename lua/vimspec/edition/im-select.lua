--- load im-select, for zh-en co-edition
--- @module vimspec.edition.im-select
local M = {}
local util = require("utils.functions")

function has_im_select()
	if util.executable("macism") then
		return true
	end
	if util.executable("fcitx-remote") or util.executable("fcitx5-remote") or util.executable("ibus") then
		return true
	end
	return false
end

M.setup = function()
	local loaded, im_select = pcall(require, "im_select")
	if loaded then
		im_select.setup()
	end
end

M.spec = function()
	return {
		"keaising/im-select.nvim",
		enabled = has_im_select(),
	}
end

return M
