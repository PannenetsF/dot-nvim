--- nvim-dap for debugging
--- @module vimspec.programming.nvim-dap
local icons = require("utils.icons")
local M = {}

M.normal_key_map = {
	d = {
		name = "Debug",
		b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
		B = {
			function()
				require("dap").toggle_breakpoint(vim.fn.input("Breakpoint Condition: "), nil, nil, true)
			end,
			"Toggle Breakpoint",
		},
		c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
		C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
		d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
		g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
		i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
		n = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
		o = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
		p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
		r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
		s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
		q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
		v = { "<cmd>DapViewToggle<cr>", "Toggle Plain View" },
		u = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
	},
}

M.terminal_key_map = {
	["<F5>"] = { ":lua require'dap'.continue()<cr>", desc = "Continue to breakpoint" },
	["<F3>"] = { ":lua require'dap'.terminate()<cr>", desc = "Terminate debugging" },
}

local ui_config = {
	icons = { expanded = "", collapsed = "", circular = "" },
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	-- Use this to override mappings for specific elements
	element_mappings = {},
	expand_lines = true,
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.33 },
				{ id = "breakpoints", size = 0.17 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 0.33,
			position = "right",
		},
		{
			elements = {
				{ id = "repl", size = 0.45 },
				{ id = "console", size = 0.55 },
			},
			size = 0.27,
			position = "bottom",
		},
	},
	controls = {
		enabled = true,
		-- Display controls in this element
		element = "repl",
		icons = {
			pause = "",
			play = "",
			step_into = "",
			step_over = "",
			step_out = "",
			step_back = "",
			run_last = "",
			terminate = "",
		},
	},
	floating = {
		max_height = 0.9,
		max_width = 0.5, -- Floats will be treated as percentage of your screen.
		border = "rounded",
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
	render = {
		max_type_length = nil, -- Can be integer or nil.
		max_value_lines = 100, -- Can be integer or nil.
	},
}

local dap_config = {
	breakpoint = {
		text = icons.ui.Bug,
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	},
	breakpoint_rejected = {
		text = icons.ui.Bug,
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	},
	stopped = {
		text = icons.ui.BoldArrowRight,
		texthl = "DiagnosticSignWarn",
		linehl = "Visual",
		numhl = "DiagnosticSignWarn",
	},
}

M.setup = function()
	require("dapui").setup(ui_config)
	vim.fn.sign_define("DapBreakpoint", dap_config.breakpoint)
	vim.fn.sign_define("DapBreakpointRejected", dap_config.breakpoint_rejected)
	vim.fn.sign_define("DapStopped", dap_config.stopped)

	local dap = require("dap")

	local keymap = vim.keymap
	local function set(mode, lhs, rhs)
		keymap.set(mode, lhs, rhs, { silent = true })
	end

	dap.listeners.after.event_initialized["me.dap.keys"] = function()
		set("n", "<up>", dap.up)
		set("n", "<down>", dap.step_over)
		set("n", "<left>", dap.step_out)
		set("n", "<right>", dap.step_into)
	end
	local reset_keys = function()
		pcall(keymap.del, "n", "<up>")
		pcall(keymap.del, "n", "<down>")
		pcall(keymap.del, "n", "<left>")
		pcall(keymap.del, "n", "<right>")
	end
	dap.listeners.after.event_terminated["me.dap.keys"] = reset_keys
	dap.listeners.after.disconnected["me.dap.keys"] = reset_keys
end

M.spec = function()
	return {
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			"igorlfs/nvim-dap-view",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"mfussenegger/nvim-dap-python",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			require("dap-python").setup()
			local dap = require("dap")
			dap.configurations.c = {
				{
					name = "Launch",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
			}
			dap.configurations.cpp = dap.configurations.c
			require("nvim-dap-virtual-text").setup()
		end,
	}
end

return M
