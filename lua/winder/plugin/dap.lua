local dap, dapui = require("dap"), require("dapui")

require("dapui").setup()

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

vim.keymap.set("n", "<Leader>b", function()
	dap.toggle_breakpoint()
end)

vim.keymap.set("n", "<F5>", function()
	dap.continue()
end)

local dap = require("dap")
require("dapui").setup(opts)

dap.listeners.after.event_initialized["dapui_config"] = function()
	require("dapui").open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	-- Commented to prevent DAP UI from closing when unit tests finish
	-- require('dapui').close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	-- Commented to prevent DAP UI from closing when unit tests finish
	-- require('dapui').close()
end

-- Add dap configurations based on your language/adapter settings
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
dap.configurations.java = {
	{
		name = "Debug Launch (2GB)",
		type = "java",
		request = "launch",
		vmArgs = "" .. "-Xmx2g ",
	},
	{
		name = "Debug Attach (8000)",
		type = "java",
		request = "attach",
		hostName = "127.0.0.1",
		port = 8000,
	},
	{
		name = "Debug Attach (5005)",
		type = "java",
		request = "attach",
		hostName = "127.0.0.1",
		port = 5005,
	},
	{
		name = "My Custom Java Run Configuration",
		type = "java",
		request = "launch",
		-- You need to extend the classPath to list your dependencies.
		-- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
		-- classPaths = {},

		-- If using multi-module projects, remove otherwise.
		-- projectName = "yourProjectName",

		-- javaExec = "java",
		mainClass = "replace.with.your.fully.qualified.MainClass",

		-- If using the JDK9+ module system, this needs to be extended
		-- `nvim-jdtls` would automatically populate this property
		-- modulePaths = {},
		vmArgs = "" .. "-Xmx2g ",
	},
}
