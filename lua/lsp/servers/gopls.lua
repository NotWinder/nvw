-- Go Language Server configuration
return {
	"gopls",
	enabled = nixCats("lsps.go") or false,
	lsp = {
		filetypes = { "go" },
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
				gofumpt = true,
			},
		},
	},
}
