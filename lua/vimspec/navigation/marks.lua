--- Enhanced Vim marks and annotated bookmarks.
--- @module vimspec.navigation.marks

local M = {}
M.annotations_visible = true
M.state_file = vim.fn.stdpath("state") .. "/vimspec/marks-bookmarks.json"

local ANNOTATION_VIRT_LINES_ABOVE = false

M.which_key_groups = {
	{ "m", group = "Marks", mode = "n" },
}

local function get_line(bufnr, line)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return nil
	end
	if line < 1 or line > vim.api.nvim_buf_line_count(bufnr) then
		return nil
	end

	local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, line - 1, line, false)
	return ok and lines[1] or nil
end

local function open_loclist(items)
	vim.fn.setloclist(0, items, "r")
	vim.cmd("lopen")
end

local function json_encode(data)
	if vim.json and vim.json.encode then
		return vim.json.encode(data)
	end
	return vim.fn.json_encode(data)
end

local function json_decode(data)
	if vim.json and vim.json.decode then
		return vim.json.decode(data)
	end
	return vim.fn.json_decode(data)
end

local function normalize_path(path)
	if not path or path == "" then
		return nil
	end

	local uv = vim.uv or vim.loop
	local ok, realpath = pcall(uv.fs_realpath, path)
	return (ok and realpath) or vim.fn.fnamemodify(path, ":p")
end

local function buffer_path(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return nil
	end
	return normalize_path(vim.api.nvim_buf_get_name(bufnr))
end

local function empty_state()
	return { version = 1, files = {} }
end

local function read_state()
	if vim.fn.filereadable(M.state_file) == 0 then
		return empty_state()
	end

	local ok, lines = pcall(vim.fn.readfile, M.state_file)
	if not ok then
		return empty_state()
	end

	local ok_decode, decoded = pcall(json_decode, table.concat(lines, "\n"))
	if not ok_decode or type(decoded) ~= "table" then
		return empty_state()
	end

	decoded.files = decoded.files or {}
	return decoded
end

local function write_state(state)
	local dir = vim.fn.fnamemodify(M.state_file, ":h")
	vim.fn.mkdir(dir, "p")
	vim.fn.writefile({ json_encode(state) }, M.state_file)
end

local function annotation_text_from_virt_lines(virt_lines)
	if type(virt_lines) ~= "table" then
		return nil
	end

	local lines = {}
	for _, virt_line in ipairs(virt_lines) do
		local chunks = {}
		for _, chunk in ipairs(virt_line) do
			if type(chunk) == "table" and type(chunk[1]) == "string" then
				table.insert(chunks, chunk[1])
			end
		end
		if #chunks > 0 then
			table.insert(lines, table.concat(chunks, ""))
		end
	end

	return #lines > 0 and table.concat(lines, "\n") or nil
end

local function indent_text(text)
	if type(text) ~= "string" or text == "" then
		return "(none)"
	end

	return text:gsub("\n", "\n    ")
end

local function virt_lines_from_text(text)
	if type(text) ~= "string" or text == "" then
		return nil
	end

	local lines = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		table.insert(lines, { { line, "MarkVirtTextHL" } })
	end
	return lines
end

local function bookmark_under_cursor()
	local marks = require("marks")
	local state = marks.bookmark_state
	local bufnr = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_win_get_cursor(0)[1]

	for group_nr, group in pairs(state.groups or {}) do
		local bookmark = group.marks[bufnr] and group.marks[bufnr][line]
		if bookmark then
			return group_nr, group, bookmark, bufnr
		end
	end
end

local function bookmark_for_annotation()
	local group_nr, group, bookmark, bufnr = bookmark_under_cursor()
	if group_nr then
		return group_nr, group, bookmark, bufnr
	end

	local marks = require("marks")
	local state = marks.bookmark_state
	bufnr = vim.api.nvim_get_current_buf()
	local prev_line = vim.api.nvim_win_get_cursor(0)[1] - 1
	if prev_line < 1 then
		return
	end

	for prev_group_nr, prev_group in pairs(state.groups or {}) do
		local prev_bookmark = prev_group.marks[bufnr] and prev_group.marks[bufnr][prev_line]
		if prev_bookmark then
			return prev_group_nr, prev_group, prev_bookmark, bufnr
		end
	end
end

local function clear_bookmark_annotation(group, bookmark, bufnr)
	pcall(vim.api.nvim_buf_del_extmark, bufnr, group.ns, bookmark.extmark_id)

	local opts = {}
	if group.virt_text and group.virt_text ~= "" then
		opts.virt_text = { { group.virt_text, "MarkVirtTextHL" } }
		opts.virt_text_pos = "eol"
	end

	bookmark.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, group.ns, bookmark.line - 1, bookmark.col, opts)
end

local function get_bookmark_details(group, bookmark, bufnr)
	local extmark = vim.api.nvim_buf_get_extmark_by_id(bufnr, group.ns, bookmark.extmark_id, { details = true })
	return extmark[3] or {}
end

local function set_bookmark_annotation(group, bookmark, bufnr, virt_lines)
	pcall(vim.api.nvim_buf_del_extmark, bufnr, group.ns, bookmark.extmark_id)
	bookmark.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, group.ns, bookmark.line - 1, bookmark.col, {
		virt_lines = virt_lines,
		virt_lines_above = ANNOTATION_VIRT_LINES_ABOVE,
	})
end

local function remember_bookmark_annotation(group, bookmark, bufnr)
	local details = get_bookmark_details(group, bookmark, bufnr)
	if details.virt_lines and #details.virt_lines > 0 then
		bookmark.annotation_virt_lines = details.virt_lines
		bookmark.annotation_virt_lines_above = ANNOTATION_VIRT_LINES_ABOVE
		if (details.virt_lines_above ~= false) ~= ANNOTATION_VIRT_LINES_ABOVE then
			set_bookmark_annotation(group, bookmark, bufnr, details.virt_lines)
		end
		return true
	end

	bookmark.annotation_virt_lines = nil
	bookmark.annotation_virt_lines_above = nil
	return false
end

local function has_visible_bookmark_annotation(group, bookmark, bufnr)
	local details = get_bookmark_details(group, bookmark, bufnr)
	if details.virt_lines and #details.virt_lines > 0 then
		bookmark.annotation_virt_lines = details.virt_lines
		bookmark.annotation_virt_lines_above = ANNOTATION_VIRT_LINES_ABOVE
		return true
	end
	return false
end

local function each_valid_bookmark(fn)
	local marks = require("marks")

	for _, group in pairs(marks.bookmark_state.groups or {}) do
		for bufnr, buffer_marks in pairs(group.marks or {}) do
			if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				for _, bookmark in pairs(buffer_marks) do
					if bookmark.line >= 1 and bookmark.line <= line_count then
						fn(group, bookmark, bufnr)
					end
				end
			end
		end
	end
end

local function hide_bookmark_annotation(group, bookmark, bufnr)
	local details = get_bookmark_details(group, bookmark, bufnr)
	if details.virt_lines and #details.virt_lines > 0 then
		bookmark.annotation_virt_lines = details.virt_lines
		bookmark.annotation_virt_lines_above = ANNOTATION_VIRT_LINES_ABOVE
	end

	if bookmark.annotation_virt_lines then
		clear_bookmark_annotation(group, bookmark, bufnr)
	end
end

local function show_bookmark_annotation(group, bookmark, bufnr)
	if not bookmark.annotation_virt_lines then
		return
	end

	pcall(vim.api.nvim_buf_del_extmark, bufnr, group.ns, bookmark.extmark_id)
	bookmark.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, group.ns, bookmark.line - 1, bookmark.col, {
		virt_lines = bookmark.annotation_virt_lines,
		virt_lines_above = ANNOTATION_VIRT_LINES_ABOVE,
	})
end

local function ensure_bookmark_group(state, group_nr)
	if not state.groups[group_nr] then
		state:init(group_nr)
	end
	return state.groups[group_nr]
end

local function remove_bookmark_extmark(group, bookmark, bufnr)
	if bookmark.sign_id then
		pcall(vim.fn.sign_unplace, "BookmarkSigns", { buffer = bufnr, id = bookmark.sign_id })
	end
	if bookmark.extmark_id then
		pcall(vim.api.nvim_buf_del_extmark, bufnr, group.ns, bookmark.extmark_id)
	end
end

local function collect_buffer_bookmarks(bufnr)
	local marks = require("marks")
	local path = buffer_path(bufnr)
	if not path then
		return nil
	end

	local bookmarks = {}
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	for group_nr, group in pairs(marks.bookmark_state.groups or {}) do
		for line, bookmark in pairs(group.marks[bufnr] or {}) do
			local bookmark_line = tonumber(bookmark.line or line)
			if bookmark_line and bookmark_line >= 1 and bookmark_line <= line_count then
				local details = get_bookmark_details(group, bookmark, bufnr)
				local annotation = annotation_text_from_virt_lines(details.virt_lines)
					or annotation_text_from_virt_lines(bookmark.annotation_virt_lines)

				table.insert(bookmarks, {
					group = group_nr,
					line = bookmark_line,
					col = tonumber(bookmark.col) or 0,
					annotation = annotation,
				})
			end
		end
	end

	table.sort(bookmarks, function(a, b)
		if a.line == b.line then
			return a.group < b.group
		end
		return a.line < b.line
	end)

	return path, bookmarks
end

local function format_buffer_export(bufnr)
	local path, bookmarks = collect_buffer_bookmarks(bufnr)
	if not path then
		return nil
	end

	local lines = {
		"# Bookmark annotations",
		"",
		"File: `" .. path .. "`",
		"",
	}

	if #bookmarks == 0 then
		table.insert(lines, "(no bookmarks)")
		return table.concat(lines, "\n"), path, 0
	end

	for _, bookmark in ipairs(bookmarks) do
		local source = get_line(bufnr, bookmark.line) or ""
		table.insert(lines, "## L" .. bookmark.line .. ":C" .. (bookmark.col + 1) .. " group " .. bookmark.group)
		table.insert(lines, "")
		table.insert(lines, "Source:")
		table.insert(lines, "    " .. source)
		table.insert(lines, "")
		table.insert(lines, "Annotation:")
		table.insert(lines, "    " .. indent_text(bookmark.annotation))
		table.insert(lines, "")
	end

	return table.concat(lines, "\n"), path, #bookmarks
end

local function update_buffer_state(state, bufnr)
	local path, bookmarks = collect_buffer_bookmarks(bufnr)
	if not path then
		return
	end

	if #bookmarks == 0 then
		state.files[path] = nil
	else
		state.files[path] = { bookmarks = bookmarks }
	end
end

local function restore_bookmark(bufnr, item)
	local marks = require("marks")
	local state = marks.bookmark_state
	local group_nr = tonumber(item.group) or 0
	local line = tonumber(item.line)
	local col = tonumber(item.col) or 0

	if not line or line < 1 or line > vim.api.nvim_buf_line_count(bufnr) then
		return
	end

	local group = ensure_bookmark_group(state, group_nr)
	group.marks[bufnr] = group.marks[bufnr] or {}

	if group.marks[bufnr][line] then
		remove_bookmark_extmark(group, group.marks[bufnr][line], bufnr)
	end

	local bookmark = {
		buf = bufnr,
		line = line,
		col = col,
		sign_id = -1,
	}

	local display_signs = state.opt.signs
	if state.opt.buf_signs and state.opt.buf_signs[bufnr] ~= nil then
		display_signs = state.opt.buf_signs[bufnr]
	end
	if display_signs and group.sign then
		local sign_id = group.sign:byte() * 100 + line
		state:add_sign(bufnr, group.sign, line, sign_id)
		bookmark.sign_id = sign_id
	end

	local annotation = virt_lines_from_text(item.annotation)
	if annotation then
		bookmark.annotation_virt_lines = annotation
		bookmark.annotation_virt_lines_above = ANNOTATION_VIRT_LINES_ABOVE
	end

	bookmark.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, group.ns, line - 1, col, {})
	group.marks[bufnr][line] = bookmark

	if annotation and M.annotations_visible then
		show_bookmark_annotation(group, bookmark, bufnr)
	end
end

M.save_buffer = function(bufnr)
	bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or (bufnr or vim.api.nvim_get_current_buf())
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end

	local state = read_state()
	update_buffer_state(state, bufnr)
	write_state(state)
end

M.save_state = function()
	local state = read_state()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) and buffer_path(bufnr) then
			update_buffer_state(state, bufnr)
		end
	end
	write_state(state)
end

M.restore_buffer = function(bufnr)
	bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or (bufnr or vim.api.nvim_get_current_buf())
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end
	if vim.b[bufnr].vimspec_marks_restored then
		return
	end

	local path = buffer_path(bufnr)
	if not path then
		return
	end

	local state = read_state()
	local file_state = state.files[path]
	if type(file_state) ~= "table" or type(file_state.bookmarks) ~= "table" then
		vim.b[bufnr].vimspec_marks_restored = true
		return
	end

	for _, item in ipairs(file_state.bookmarks) do
		restore_bookmark(bufnr, item)
	end
	vim.b[bufnr].vimspec_marks_restored = true
end

M.restore_loaded_buffers = function()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			M.restore_buffer(bufnr)
		end
	end
end

M.list_buffer_marks = function()
	local marks = require("marks")
	local bufnr = vim.api.nvim_get_current_buf()
	local buffer_state = marks.mark_state.buffers[bufnr]
	local items = {}

	if buffer_state then
		for mark, data in pairs(buffer_state.placed_marks or {}) do
			local text = get_line(bufnr, data.line)
			if text then
				table.insert(items, {
					bufnr = bufnr,
					lnum = data.line,
					col = data.col + 1,
					text = "mark " .. mark .. ": " .. text,
				})
			end
		end
	end

	open_loclist(items)
end

M.list_all_marks = function()
	local marks = require("marks")
	local items = {}

	for bufnr, buffer_state in pairs(marks.mark_state.buffers or {}) do
		for mark, data in pairs(buffer_state.placed_marks or {}) do
			local text = get_line(bufnr, data.line)
			if text then
				table.insert(items, {
					bufnr = bufnr,
					lnum = data.line,
					col = data.col + 1,
					text = "mark " .. mark .. ": " .. text,
				})
			end
		end
	end

	open_loclist(items)
end

M.list_all_bookmarks = function()
	local marks = require("marks")
	local items = {}

	for group_nr, group in pairs(marks.bookmark_state.groups or {}) do
		for bufnr, buffer_marks in pairs(group.marks or {}) do
			for line, bookmark in pairs(buffer_marks) do
				local text = get_line(bufnr, line)
				if text then
					table.insert(items, {
						bufnr = bufnr,
						lnum = line,
						col = bookmark.col + 1,
						text = "bookmark group " .. group_nr .. ": " .. text,
					})
				end
			end
		end
	end

	open_loclist(items)
end

M.export_buffer_to_clipboard = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local export, path, count = format_buffer_export(bufnr)
	if not export then
		return
	end

	vim.fn.setreg('"', export)
	vim.fn.setreg("+", export)
	require("utils.functions").copy_to_clipboard(export, "+")
	vim.notify(
		string.format("Copied %d bookmark annotation%s from %s", count, count == 1 and "" or "s", path),
		vim.log.levels.INFO
	)
end

M.set_annotated_bookmark0 = function()
	require("marks").set_bookmark0()

	local group_nr, group, bookmark, bufnr = bookmark_under_cursor()
	if not group_nr then
		return
	end

	remember_bookmark_annotation(group, bookmark, bufnr)
	if not M.annotations_visible then
		hide_bookmark_annotation(group, bookmark, bufnr)
	end
	M.save_buffer(bufnr)
end

M.set_annotation = function()
	local group_nr, group, bookmark, bufnr = bookmark_for_annotation()
	if not group_nr then
		return
	end

	local text = vim.fn.input("annotation: ")
	if text ~= "" then
		bookmark.annotation_virt_lines = virt_lines_from_text(text)
		bookmark.annotation_virt_lines_above = ANNOTATION_VIRT_LINES_ABOVE
		if M.annotations_visible then
			show_bookmark_annotation(group, bookmark, bufnr)
		else
			clear_bookmark_annotation(group, bookmark, bufnr)
		end
	else
		bookmark.annotation_virt_lines = nil
		bookmark.annotation_virt_lines_above = nil
		clear_bookmark_annotation(group, bookmark, bufnr)
	end

	if not M.annotations_visible then
		hide_bookmark_annotation(group, bookmark, bufnr)
	end
	M.save_buffer(bufnr)
end

M.delete_bookmark = function()
	require("marks").delete_bookmark()
	M.save_buffer(0)
end

M.clear_annotation = function()
	local group_nr, group, bookmark, bufnr = bookmark_for_annotation()
	if not group_nr then
		return
	end

	bookmark.annotation_virt_lines = nil
	bookmark.annotation_virt_lines_above = nil
	clear_bookmark_annotation(group, bookmark, bufnr)
	M.save_buffer(bufnr)
end

M.toggle_annotations_display = function()
	local has_visible = false

	each_valid_bookmark(function(group, bookmark, bufnr)
		if has_visible_bookmark_annotation(group, bookmark, bufnr) then
			has_visible = true
		end
	end)

	M.annotations_visible = not has_visible

	each_valid_bookmark(function(group, bookmark, bufnr)
		if M.annotations_visible then
			show_bookmark_annotation(group, bookmark, bufnr)
		else
			hide_bookmark_annotation(group, bookmark, bufnr)
		end
	end)
end

local function setup_persistence_autocmds()
	local group = vim.api.nvim_create_augroup("VimspecMarksPersistence", { clear = true })

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
		group = group,
		callback = function(args)
			M.restore_buffer(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			pcall(M.save_state)
		end,
	})
end

local function setup_commands()
	vim.api.nvim_create_user_command("MarksExportAnnotations", function()
		M.export_buffer_to_clipboard()
	end, {})
end

M.setup = function()
	require("marks").setup({
		default_mappings = false,
		builtin_marks = { ".", "<", ">", "^" },
		cyclic = true,
		force_write_shada = false,
		refresh_interval = 250,
		sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
		excluded_filetypes = {},
		excluded_buftypes = {},
		bookmark_0 = {
			sign = "M",
			annotate = true,
		},
	})

	setup_persistence_autocmds()
	setup_commands()
	vim.schedule(M.restore_loaded_buffers)
end

M.spec = function()
	return {
		"chentoast/marks.nvim",
		event = "VeryLazy",
		keys = {
			{
				"m,",
				function()
					require("marks").set_next()
				end,
				desc = "Set next mark",
				mode = "n",
			},
			{
				"m;",
				function()
					require("marks").toggle()
				end,
				desc = "Toggle mark",
				mode = "n",
			},
			{
				"m]",
				function()
					require("marks").next()
				end,
				desc = "Next mark",
				mode = "n",
			},
			{
				"m[",
				function()
					require("marks").prev()
				end,
				desc = "Previous mark",
				mode = "n",
			},
			{
				"m:",
				function()
					require("marks").preview()
				end,
				desc = "Preview mark",
				mode = "n",
			},
			{
				"m0",
				function()
					M.set_annotated_bookmark0()
				end,
				desc = "Set annotated bookmark",
				mode = "n",
			},
			{
				"m?",
				function()
					M.set_annotation()
				end,
				desc = "Set bookmark annotation",
				mode = "n",
			},
			{
				"m!",
				function()
					M.toggle_annotations_display()
				end,
				desc = "Toggle annotation display",
				mode = "n",
			},
			{
				"mc",
				function()
					M.clear_annotation()
				end,
				desc = "Clear bookmark annotation",
				mode = "n",
			},
			{
				"md",
				function()
					M.delete_bookmark()
				end,
				desc = "Delete bookmark",
				mode = "n",
			},
			{
				"m}",
				function()
					require("marks").next_bookmark0()
				end,
				desc = "Next bookmark",
				mode = "n",
			},
			{
				"m{",
				function()
					require("marks").prev_bookmark0()
				end,
				desc = "Previous bookmark",
				mode = "n",
			},
			{
				"m/",
				function()
					M.list_all_bookmarks()
				end,
				desc = "List Bookmarks",
				mode = "n",
			},
			{
				"m|",
				function()
					M.list_all_marks()
				end,
				desc = "List All Marks",
				mode = "n",
			},
			{
				"m\\",
				function()
					M.list_buffer_marks()
				end,
				desc = "List Buffer Marks",
				mode = "n",
			},
			{
				"ym",
				function()
					M.export_buffer_to_clipboard()
				end,
				desc = "Yank bookmark annotations",
				mode = "n",
			},
			{
				"dm",
				function()
					require("marks").delete()
				end,
				desc = "Delete mark",
				mode = "n",
			},
			{
				"dm-",
				function()
					require("marks").delete_line()
				end,
				desc = "Delete line marks",
				mode = "n",
			},
			{
				"dm=",
				function()
					M.delete_bookmark()
				end,
				desc = "Delete bookmark",
				mode = "n",
			},
			{
				"dm<space>",
				function()
					require("marks").delete_buf()
				end,
				desc = "Delete buffer marks",
				mode = "n",
			},
		},
		config = function()
			M.setup()
		end,
	}
end

return M
