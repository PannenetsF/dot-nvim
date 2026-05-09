--- Alpha-nvim configuration for splash screen
--- @module vimspec.ui.alpha-nvim
local M = {}

local emacs_logo_fallback = {
	[[               .-=================-.               ]],
	[[             .=======================.             ]],
	[[           .===========================.           ]],
	[[          :=======----=======----=======:          ]],
	[[         :======:       =====       :======:       ]],
	[[         =======        =====        =======       ]],
	[[         :======:       =====       :======:       ]],
	[[          :=======----=======----=======:          ]],
	[[           .===========================.           ]],
	[[               .-=================-.               ]],
}

local logo_path = vim.fn.stdpath("config") .. "/assets/Nuvola_apps_emacs_vector.png"
local logo_height = 10
local logo_width = 20
local logo_start_line = 2
local alpha_logo_augroup = vim.api.nvim_create_augroup("alpha_nuvola_emacs_logo", { clear = true })

local function blank_logo_lines()
	local lines = {}
	local padding = string.rep(" ", math.max(0, math.floor((vim.o.columns - logo_width) / 2)))
	for _ = 1, logo_height do
		table.insert(lines, padding)
	end
	return lines
end

local function supports_inline_image(path)
	local ok, image = pcall(require, "snacks.image")
	if not ok then
		return false
	end

	return vim.fn.filereadable(path) == 1 and image.supports(path)
end

local function set_fallback_logo(bufnr)
	local fallback = {}
	local column = math.max(0, math.floor((vim.o.columns - vim.fn.strdisplaywidth(emacs_logo_fallback[1])) / 2))
	local padding = string.rep(" ", column)
	for _, line in ipairs(emacs_logo_fallback) do
		table.insert(fallback, padding .. line)
	end
	local modifiable = vim.bo[bufnr].modifiable
	vim.bo[bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(bufnr, logo_start_line, logo_start_line + logo_height, false, fallback)
	vim.bo[bufnr].modifiable = modifiable
end

local function logo_column(bufnr)
	local line = vim.api.nvim_buf_get_lines(bufnr, logo_start_line, logo_start_line + 1, false)[1] or ""
	local whitespace = line:match("^%s*") or ""

	return vim.fn.strdisplaywidth(whitespace)
end

local function render_alpha_logo(force_fallback)
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].filetype ~= "alpha" then
		return
	end

	pcall(require("snacks.image.placement").clean, bufnr)

	if force_fallback or not supports_inline_image(logo_path) then
		set_fallback_logo(bufnr)
		return
	end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if line_count < logo_height then
		return
	end

	require("snacks.image.placement").new(bufnr, logo_path, {
		inline = true,
		auto_resize = true,
		width = logo_width,
		height = logo_height,
		pos = { logo_start_line + 1, logo_column(bufnr) },
		type = "image",
	})
end

local function render_alpha_logo_after_detect()
	local ok, terminal = pcall(require, "snacks.image.terminal")
	if not ok then
		render_alpha_logo(true)
		return
	end

	terminal.detect(function()
		vim.schedule(render_alpha_logo)
	end)
end

M.setup = function()
	local theta = require("alpha.themes.theta")
	theta.header.val = blank_logo_lines()
	theta.config.layout[1].val = 1
	theta.config.layout[3].val = 1
	local theta_setup = theta.config.opts.setup
	theta.config.opts.setup = function()
		if theta_setup then
			theta_setup()
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "AlphaReady",
			group = alpha_logo_augroup,
			callback = function()
				vim.schedule(render_alpha_logo_after_detect)
			end,
		})
		vim.api.nvim_create_autocmd("VimResized", {
			group = alpha_logo_augroup,
			callback = function()
				vim.schedule(render_alpha_logo_after_detect)
			end,
		})
	end
	require("alpha").setup(require("alpha.themes.theta").config)
end

M.spec = function()
	return {
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	}
end

return M
