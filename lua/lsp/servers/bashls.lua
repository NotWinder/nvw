-- Bash Language Server configuration
return {
	"bashls",
	enabled = nixCats("lsps.bash") or false,
	lsp = {
		filetypes = { "sh", "bash" },
	},
}
