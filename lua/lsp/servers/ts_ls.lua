-- TypeScript/JavaScript Language Server configuration
return {
	"ts_ls",
	enabled = nixCats("lsps.javascript") or false,
	lsp = {
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
}
