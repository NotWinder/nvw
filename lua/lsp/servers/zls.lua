-- Zig Language Server configuration
return {
	"zls",
	enabled = nixCats("lsps.zig") or false,
	lsp = {
		filetypes = { "zig" },
	},
}
