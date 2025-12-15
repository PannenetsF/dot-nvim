--- load github copilot
--- @module vimspec.programming.copilot
local M = {}

local function _mangle_safety(str)
	local mapping = {
		["a"] = "z",
		["b"] = "y",
		["c"] = "x",
		["d"] = "w",
		["e"] = "v",
		["f"] = "u",
		["g"] = "t",
		["h"] = "s",
		["i"] = "r",
		["j"] = "q",
		["k"] = "p",
		["l"] = "o",
		["m"] = "n",
		["n"] = "m",
		["o"] = "l",
		["p"] = "k",
		["q"] = "j",
		["r"] = "i",
		["s"] = "h",
		["t"] = "g",
		["u"] = "f",
		["v"] = "e",
		["w"] = "d",
		["x"] = "c",
		["y"] = "b",
		["z"] = "a",

		["A"] = "Z",
		["B"] = "Y",
		["C"] = "X",
		["D"] = "W",
		["E"] = "V",
		["F"] = "U",
		["G"] = "T",
		["H"] = "S",
		["I"] = "R",
		["J"] = "Q",
		["K"] = "P",
		["L"] = "O",
		["M"] = "N",
		["N"] = "M",
		["O"] = "L",
		["P"] = "K",
		["Q"] = "J",
		["R"] = "I",
		["S"] = "H",
		["T"] = "G",
		["U"] = "F",
		["V"] = "E",
		["W"] = "D",
		["X"] = "C",
		["Y"] = "B",
		["Z"] = "A",

		["0"] = "9",
		["1"] = "8",
		["2"] = "7",
		["3"] = "6",
		["4"] = "5",
		["5"] = "4",
		["6"] = "3",
		["7"] = "2",
		["8"] = "1",
		["9"] = "0",
	}

	local result = ""

	for i = 1, #str do
		local char = str:sub(i, i)
		if mapping[char] then
			result = result .. mapping[char]
		else
			result = result .. char
		end
	end

	return result
end

M.setup = function()
	vim.g.trae_no_map_tab = true
	vim.api.nvim_set_keymap("i", "<C-E>", 'trae#Accept("<CR>")', { silent = true, expr = true })
end

M.spec = function()
	return {
		_mangle_safety("sggkh://xlwv.ybgvw.lit/xsvmqrzjr.xklhgfiv/xlwvevihv.ern.trg"),
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("trae").setup({})
		end,
	}
end

return M
