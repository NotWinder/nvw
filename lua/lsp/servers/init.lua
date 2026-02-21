-- LSP Server configurations aggregator
-- Returns a list of all server specs to be loaded
return {
	require("lsp.servers.lua_ls"),
	require("lsp.servers.basedpyright"),
	require("lsp.servers.gopls"),
	require("lsp.servers.nixd"),
	require("lsp.servers.rust_analyzer"),
	require("lsp.servers.ts_ls"),
	require("lsp.servers.bashls"),
	require("lsp.servers.yamlls"),
	require("lsp.servers.zls"),
	require("lsp.servers.qmlls"),
}
