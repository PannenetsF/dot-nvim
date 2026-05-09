--- Commands for maintaining this Neovim config.
--- @module vimconf.config-update

local M = {}

local update_running = false

local function notify(message, level)
	vim.schedule(function()
		vim.notify(message, level, { title = "Nvim config" })
	end)
end

local function collect_output(result)
	local chunks = {}
	if result.stdout and result.stdout ~= "" then
		table.insert(chunks, vim.trim(result.stdout))
	end
	if result.stderr and result.stderr ~= "" then
		table.insert(chunks, vim.trim(result.stderr))
	end

	return vim.trim(table.concat(chunks, "\n"))
end

local function nvim_config_update()
	if update_running then
		vim.notify("Nvim config update is already running", vim.log.levels.INFO, { title = "Nvim config" })
		return
	end

	if vim.fn.executable("git") == 0 then
		vim.notify("git executable not found", vim.log.levels.ERROR, { title = "Nvim config" })
		return
	end

	update_running = true
	local config_dir = vim.fn.stdpath("config")
	vim.notify("Updating Nvim config...", vim.log.levels.INFO, { title = "Nvim config" })

	vim.system({ "git", "-C", config_dir, "pull", "--ff-only" }, { text = true }, function(result)
		update_running = false
		local output = collect_output(result)

		if result.code == 0 then
			if output == "" then
				output = "Already up to date."
			end
			notify(output, vim.log.levels.INFO)
			return
		end

		local message = string.format("Update failed with exit code %d", result.code)
		if output ~= "" then
			message = message .. "\n" .. output
		end
		notify(message, vim.log.levels.ERROR)
	end)
end

M.conf = function()
	vim.api.nvim_create_user_command("NvimCfgUpdate", nvim_config_update, {
		desc = "Update this Neovim config with git pull --ff-only",
		force = true,
	})
end

return M
