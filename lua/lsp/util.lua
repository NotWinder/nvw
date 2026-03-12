-- LSP Utility functions
-- Provides helpers for Python path detection
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

return M
