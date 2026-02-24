-- Lua Language Server configuration
return {
	"lua_ls",
	enabled = nixCats("lsps.lua") or false,
	lsp = {
		filetypes = { "lua" },
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				format = {
					-- stylua handles formatting via conform; disable lua_ls formatter
					enable = false,
				},
				signatureHelp = {
					enabled = true,
				},
				diagnostics = {
					globals = { "nixCats", "vim" },
					disable = { "missing-fields" },
				},
				telemetry = {
					enabled = false,
				},
			},
		},
	},
}
