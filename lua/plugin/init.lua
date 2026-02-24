require("lze").register_handlers(require("lzextras").lsp)
require("plugin.general")
require("plugin.lsp")
-- Load necessary plugins using lze
require("lze").load({
	{ import = "plugin.completions" },
	{ import = "plugin.copilot" },
	{ import = "plugin.format" },
	{ import = "plugin.ai" },
})
