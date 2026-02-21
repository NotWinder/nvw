-- QML Language Server configuration
return {
	"qmlls",
	enabled = nixCats("lsps.qml") or false,
	lsp = {
		filetypes = { "qml" },
		cmd = { "qmlls", "-E" },
	},
}
