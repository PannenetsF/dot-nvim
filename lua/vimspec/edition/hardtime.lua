-- This module provides hardtime
--- @module vimspec.edition.hardtime

local M = {}

function M.setup()
	require("hardtime").setup()
end

M.spec = function()
  return {
   "m4xshen/hardtime.nvim",
   lazy = false,
   dependencies = { "MunifTanjim/nui.nvim" },
   opts = {},
}
end

return M
