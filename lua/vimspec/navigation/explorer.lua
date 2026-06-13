--- Snacks-based navigation entry points.
--- @module vimspec.navigation.explorer

local M = {}

local function open_explorer()
	Snacks.explorer.open()
end

local function open_git_status()
	Snacks.picker.git_status()
end

local function open_buffers()
	Snacks.picker.buffers()
end

local function open_diagnostics()
	Snacks.picker.diagnostics()
end

M.normal_key_map = {
	["e"] = { open_explorer, "File Explorer" },
	s = {
		name = "Navigate",
		f = { open_explorer, "Filesystem" },
		g = { open_git_status, "Git Status" },
		b = { open_buffers, "Buffers" },
		d = { open_diagnostics, "Diagnostics" },
	},
}

return M
