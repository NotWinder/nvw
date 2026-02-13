require("lze").register_handlers(require("lzextras").lsp)
require("plugin.general")
require("plugin.lsp")
require("lze").load({
	{ import = "plugin.complitions" },
	{ import = "plugin.copilot" },
	{ import = "plugin.format" },
	{ import = "plugin.ai" },
})
