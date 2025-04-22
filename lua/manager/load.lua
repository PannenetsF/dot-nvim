--- configure lazy.nvim
--- @module manager.load

local M = {}

--- if it is not installed yet, clone it from github
M.make_sure_lazy_installed = function()
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not (vim.uv or vim.loop).fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			lazypath,
		})
	end
	vim.opt.rtp:prepend(lazypath)
end

--- after installation, load modules' spec from vimspec module
M.load_modules = function()
	require("lazy").setup({
		require("vimspec").setup_lazy(),
	})
end

M.setup = function()
	M.make_sure_lazy_installed()
	M.load_modules()
end

M.setup()
