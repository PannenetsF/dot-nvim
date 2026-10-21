--- nvim-dap for debugging
--- @module vimspec.programming.nvim-dap
local icons = require("utils.icons")
local M = {}

M.which_key_groups = {
	{ "<leader>d", group = "Debug", mode = "n" },
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

M.setup = function(force)
	if not force and not (package.loaded["dapui"] and package.loaded["dap"]) then
		return
	end

	local has_dapui, dapui = pcall(require, "dapui")
	local has_dap, dap = pcall(require, "dap")
	if not (has_dapui and has_dap) then
		return
	end

	dapui.setup(ui_config)
	vim.fn.sign_define("DapBreakpoint", dap_config.breakpoint)
	vim.fn.sign_define("DapBreakpointRejected", dap_config.breakpoint_rejected)
	vim.fn.sign_define("DapStopped", dap_config.stopped)

	local keymap = vim.keymap
	local function set(mode, lhs, rhs)
		keymap.set(mode, lhs, rhs, { silent = true })
	end

	local directional_keys = {
		{ lhs = "<up>", rhs = dap.up },
		{ lhs = "<down>", rhs = dap.step_over },
		{ lhs = "<left>", rhs = dap.step_out },
		{ lhs = "<right>", rhs = dap.step_into },
	}
	-- Other plugins (multicursor.nvim maps <up>/<down> globally) may own these
	-- keys before a debug session starts; snapshot them on session start so
	-- teardown restores the previous owner instead of deleting it outright.
	local saved_directional_keys = {}

	dap.listeners.after.event_initialized["me.dap.keys"] = function()
		for _, item in ipairs(directional_keys) do
			local saved = vim.fn.maparg(item.lhs, "n", false, true)
			if not vim.tbl_isempty(saved) then
				saved_directional_keys[item.lhs] = saved
			end
			set("n", item.lhs, item.rhs)
		end
	end
	local reset_keys = function()
		for _, item in ipairs(directional_keys) do
			pcall(keymap.del, "n", item.lhs)
			local saved = saved_directional_keys[item.lhs]
			if saved then
				vim.fn.mapset("n", false, saved)
			end
		end
		saved_directional_keys = {}
	end
	dap.listeners.after.event_terminated["me.dap.keys"] = reset_keys
	dap.listeners.after.disconnected["me.dap.keys"] = reset_keys
end

M.spec = function()
	return {
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
				mode = "n",
			},
			{
				"<leader>dB",
				function()
					require("dap").toggle_breakpoint(vim.fn.input("Breakpoint Condition: "), nil, nil, true)
				end,
				desc = "Toggle Breakpoint",
				mode = "n",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
				mode = "n",
			},
			{
				"<leader>dC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run To Cursor",
				mode = "n",
			},
			{
				"<leader>dd",
				function()
					require("dap").disconnect()
				end,
				desc = "Disconnect",
				mode = "n",
			},
			{
				"<leader>dg",
				function()
					require("dap").session()
				end,
				desc = "Get Session",
				mode = "n",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
				mode = "n",
			},
			{
				"<leader>dn",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
				mode = "n",
			},
			{
				"<leader>do",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
				mode = "n",
			},
			{
				"<leader>dp",
				function()
					require("dap").pause()
				end,
				desc = "Pause",
				mode = "n",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle Repl",
				mode = "n",
			},
			{
				"<leader>ds",
				function()
					require("dap").continue()
				end,
				desc = "Start",
				mode = "n",
			},
			{
				"<leader>dq",
				function()
					require("dap").close()
				end,
				desc = "Quit",
				mode = "n",
			},
			{ "<leader>dv", "<cmd>DapViewToggle<cr>", desc = "Toggle Plain View", mode = "n" },
			{
				"<leader>du",
				function()
					require("dapui").toggle({ reset = true })
				end,
				desc = "Toggle UI",
				mode = "n",
			},
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "Continue to breakpoint",
				mode = "t",
			},
			{
				"<F3>",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate debugging",
				mode = "t",
			},
		},
		dependencies = {
			"igorlfs/nvim-dap-view",
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
			},
			"mfussenegger/nvim-dap-python",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			require("dap-python").setup()
			local dap = require("dap")
			-- The C/C++ launch configuration below uses type="gdb"; without an
			-- adapter nvim-dap errors with "the following adapter can't be found: gdb"
			-- exactly when debugging starts. Register the stock gdb DAP adapter
			-- (requires gdb built with Python support, which the nix gdb is).
			if vim.fn.executable("gdb") == 1 then
				dap.adapters.gdb = {
					type = "executable",
					command = "gdb",
					args = { "-i", "dap" },
				}
			end
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
			M.setup(true)
		end,
	}
end

return M
