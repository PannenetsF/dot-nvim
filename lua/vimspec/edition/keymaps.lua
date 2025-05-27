--- Useful keybinds for edition
--- @module vimspec.edition.keymaps
local M = {}

M.normal_key_map = {
	["h"] = { "<cmd>nohlsearch<CR>", "Hide Highlight Search" },
}
M.spec = function()
	return {}
end

return M
