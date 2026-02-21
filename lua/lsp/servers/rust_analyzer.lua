-- Rust Language Server configuration
return {
	"rust_analyzer",
	enabled = nixCats("lsps.rust") or false,
	lsp = {
		filetypes = { "rust" },
	},
}
