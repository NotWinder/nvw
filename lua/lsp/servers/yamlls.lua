-- YAML Language Server configuration
return {
	"yamlls",
	enabled = nixCats("lsps.yaml") or false,
	lsp = {
		filetypes = { "yaml" },
	},
}
