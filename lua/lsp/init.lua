-- LSP Configuration Orchestrator
-- Main entry point for LSP setup - loads all modules and configures LSPs
local util = require("lsp.util")
local capabilities = require("lsp.capabilities")
local diagnostics = require("lsp.diagnostics")

-- Setup utilities and diagnostics
util.setup_filetype_fallback()
diagnostics.setup()

-- Load all server configurations
local servers = require("lsp.servers")

-- Build the spec list for lze
local specs = {
	-- nvim-lspconfig base configuration
	{
		"nvim-lspconfig",
		for_cat = "general.core",
		on_require = { "lspconfig" },
		-- LSP handler function - called for each server spec
		lsp = function(plugin)
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
		-- Global configuration applied to all LSPs
		before = function(_)
			vim.lsp.config("*", {
				capabilities = capabilities.make(),
				on_attach = require("plugin.on_attach"),
			})
		end,
	},
	-- lazydev.nvim for enhanced Lua development
	{
		"lazydev.nvim",
		for_cat = "lua",
		cmd = { "LazyDev" },
		ft = "lua",
		after = function(_)
			require("lazydev").setup({
				library = {
					{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
				},
			})
		end,
	},
}

-- Append all server specs to the main spec list
for _, server in ipairs(servers) do
	table.insert(specs, server)
end

-- Load all LSP configurations
require("lze").load(specs)
