-- BasedPyright (Python) Language Server configuration
local util = require("lsp.util")

return {
	"basedpyright",
	enabled = nixCats("lsps.python") or false,
	lsp = {
		filetypes = { "python" },
		before_init = function(_, config)
			-- Ensure the settings/python table exists before assigning pythonPath
			config.settings = config.settings or {}
			config.settings.python = config.settings.python or {}
			config.settings.python.pythonPath = util.get_python_path()
		end,
		settings = {
			basedpyright = {
				analysis = {
					typeCheckingMode = "basic",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
					diagnosticSeverityOverrides = {
						reportGeneralTypeIssues = "none",
						reportOptionalMemberAccess = "none",
						reportAttributeAccessIssue = "none",
					},
				},
			},
		},
	},
}
