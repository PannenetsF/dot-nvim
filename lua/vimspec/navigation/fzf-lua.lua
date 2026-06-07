--- fzf-lua for selection from list
--- @module vimspec.navigation.fzf

local M = {}

M.project_patterns = {
	".git",
	"_darcs",
	".hg",
	".bzr",
	".svn",
	"package.json",
	"Makefile",
}

M.recent_project_patterns = {
	".git",
	"_darcs",
	".hg",
	".bzr",
	".svn",
}

M.project_dev_dirs = {
	"~/dev",
	"~/projects",
}

M.project_root = function(path, fallback, patterns)
	local target = vim.fs.normalize(vim.fn.fnamemodify(path or (vim.uv or vim.loop).cwd(), ":p"))

	if vim.fn.isdirectory(target) == 0 then
		target = vim.fs.dirname(target) or target
	end

	local root = vim.fs.root(target, patterns or M.project_patterns)
	if root or fallback == false then
		return root
	end

	return target
end

M.add_project = function(projects, seen, dir)
	if dir == nil or dir == "" then
		return
	end

	dir = vim.fs.normalize(vim.fn.fnamemodify(dir, ":p"))
	if seen[dir] or vim.fn.isdirectory(dir) == 0 then
		return
	end

	seen[dir] = true
	table.insert(projects, dir)
end

M.recent_projects = function(projects, seen)
	for _, file in ipairs(vim.v.oldfiles) do
		M.add_project(projects, seen, M.project_root(file, false, M.recent_project_patterns))
	end
end

M.scanned_projects = function(projects, seen)
	local fd = vim.fn.executable("fd") == 1 and "fd" or vim.fn.executable("fdfind") == 1 and "fdfind" or nil
	if fd == nil then
		return
	end

	local args = {
		fd,
		"-H",
		"-t",
		"f",
		"-t",
		"s",
		"-t",
		"d",
		"--max-depth",
		"2",
		"--follow",
		"--absolute-path",
		"-g",
		"{" .. table.concat(M.project_patterns, ",") .. "}",
	}

	for _, dir in ipairs(M.project_dev_dirs) do
		local expanded = vim.fs.normalize(vim.fn.expand(dir))
		if vim.fn.isdirectory(expanded) == 1 then
			table.insert(args, expanded)
		end
	end

	if #args == 14 then
		return
	end

	for _, path in ipairs(vim.fn.systemlist(args)) do
		M.add_project(projects, seen, vim.fs.dirname(path))
	end
end

M.project_list = function()
	local projects = {}
	local seen = {}

	M.add_project(projects, seen, M.project_root())
	M.recent_projects(projects, seen)
	M.scanned_projects(projects, seen)

	return projects
end

M.selected_project = function(selected)
	local dir = selected and selected[1]
	if dir == nil or dir == "" then
		return nil
	end

	vim.cmd("tcd " .. vim.fn.fnameescape(dir))
	return dir
end

M.open_project_files = function(selected)
	local dir = M.selected_project(selected)
	if dir == nil then
		return
	end

	require("fzf-lua").files({ cwd = dir })
end

M.grep_project = function(selected)
	local dir = M.selected_project(selected)
	if dir == nil then
		return
	end

	require("fzf-lua").live_grep({ cwd = dir })
end

M.switch_project = function(selected)
	local dir = M.selected_project(selected)
	if dir == nil then
		return
	end

	vim.notify("cwd: " .. dir, vim.log.levels.INFO, { title = "Projects" })
end

M.projects = function()
	local projects = M.project_list()
	if #projects == 0 then
		vim.notify("No projects found", vim.log.levels.WARN, { title = "Projects" })
		return
	end

	require("fzf-lua").fzf_exec(projects, {
		prompt = "Projects> ",
		previewer = false,
		fzf_opts = {
			["--header"] = "enter: files | ctrl-g: grep | ctrl-w: cd only",
		},
		actions = {
			["enter"] = M.open_project_files,
			["ctrl-g"] = M.grep_project,
			["ctrl-w"] = M.switch_project,
		},
	})
end

--- fzf key mappings for searching files/buffers/help tags/git commits/...
M.normal_key_map = {
	f = {
		name = "Find",
		f = { "<cmd>FzfLua files<cr>", "Find Files" },
		F = { "<cmd>FzfLua filetypes<cr>", "Filetypes" },
		g = { "<cmd>FzfLua live_grep<cr>", "Live Grep" },
		b = { "<cmd>FzfLua buffers<cr>", "Buffers" },
		q = { "<cmd>FzfLua lgrep_quickfix<cr>", "Quick Fix" },
		h = { "<cmd>FzfLua help_tags<cr>", "Help Tags" },
		H = { "<cmd>FzfLua highlights<cr>", "Hightlight Group" },
		c = { "<cmd>FzfLua git_commits<cr>", "Git Commits" },
		p = {
			function()
				M.projects()
			end,
			"Projects",
		},
		j = { "<cmd>FzfLua jumps<cr>", "Jump Lines" },
		l = { "<cmd>FzfLua resume<cr>", "Resume last search" },
		s = { "<cmd>FzfLua search_history<cr>", "Open Recent Commands" },
		r = { "<cmd>FzfLua oldfiles<cr>", "Open Recent File" },
		R = { "<cmd>FzfLua registers<cr>", "Registers" },
		k = { "<cmd>FzfLua keymaps<cr>", "Keymaps" },
		t = { "<cmd>FzfLua treesitter<cr>", "Treesitters" },
		C = { "<cmd>FzfLua commands<cr>", "Commands" },
		m = { "<cmd>FzfLua marks<cr>", "Goto Marks" },
		P = { "<cmd>FzfLua colorschemes<cr>", "Colorscheme with Preview" },
		A = { "<cmd>FzfLua awesome_colorschemes<cr>", "Awesome Colorscheme with Preview" },
	},
}

M.setup = function() end

M.spec = function()
	return {
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	}
end

return M
