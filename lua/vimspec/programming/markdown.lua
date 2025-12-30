--- load render-markdown
--- @module vimspec.programming.markdown
local M = {}

M.spec = function()
	return {
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	}
end

return M
