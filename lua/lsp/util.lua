-- LSP Utility functions
-- Provides helpers for Python path detection and filetype fallback
local M = {}

-- Cache for Python paths per working directory
local python_path_cache = {}

--- Get the Python interpreter path for the current project
--- Checks for virtualenv in order: VIRTUAL_ENV, .venv, venv, .virtualenv
---@return string Python interpreter path
function M.get_python_path()
	local cwd = vim.fn.getcwd()

	-- Return cached path if available
	if python_path_cache[cwd] then
		return python_path_cache[cwd]
	end

	-- Check if we're in a virtualenv
	local venv = os.getenv("VIRTUAL_ENV")
	if venv then
		python_path_cache[cwd] = venv .. "/bin/python"
		return python_path_cache[cwd]
	end

	-- Check common venv locations
	local venv_paths = {
		cwd .. "/.venv/bin/python",
		cwd .. "/venv/bin/python",
		cwd .. "/.virtualenv/bin/python",
	}

	for _, path in ipairs(venv_paths) do
		if vim.fn.executable(path) == 1 then
			python_path_cache[cwd] = path
			return path
		end
	end

	-- Fallback to system python
	python_path_cache[cwd] = "python3"
	return "python3"
end

--- Set up filetype fallback for LSP configurations
--- Uses nixCats paths for faster LSP config discovery
function M.setup_filetype_fallback()
	local old_ft_fallback = require("lze").h.lsp.get_ft_fallback()

	require("lze").h.lsp.set_ft_fallback(function(name)
		-- Attempt to locate the LSP configuration in the Nix store
		local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" })
			or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })

		if lspcfg then
			-- Try to load the LSP configuration file for the given name
			local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
			if not ok then
				-- Fallback to an alternative path if the first attempt fails
				ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
			end
			-- Return the filetypes from the configuration, or an empty list if not found
			return (ok and cfg or {}).filetypes or {}
		else
			-- Use the old fallback logic if no configuration is found
			return old_ft_fallback(name)
		end
	end)
end

return M
