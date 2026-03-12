-- LSP Configuration
-- Uses Neovim 0.12+ native vim.lsp.config / vim.lsp.enable APIs
-- Servers are enabled based on whether their binary is available on PATH

--- Check if a binary is available on PATH
local function has(bin)
	return vim.fn.executable(bin) == 1
end

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {},
			},
		},
		config = function()
			local capabilities = require("lsp.capabilities").make()
			local on_attach = require("lsp.on_attach")
			local diagnostics = require("lsp.diagnostics")
			local util = require("lsp.util")

			-- Setup diagnostics
			diagnostics.setup()

			-- Global LSP defaults
			vim.lsp.config("*", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Lua
			if has("lua-language-server") then
				vim.lsp.config("lua_ls", {
					filetypes = { "lua" },
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							format = { enable = false },
							signatureHelp = { enabled = true },
							diagnostics = {
								globals = { "vim" },
								disable = { "missing-fields" },
							},
							telemetry = { enabled = false },
						},
					},
				})
				vim.lsp.enable("lua_ls")
			end

			-- Python
			if has("basedpyright") then
				vim.lsp.config("basedpyright", {
					filetypes = { "python" },
					before_init = function(_, config)
						config.settings = config.settings or {}
						config.settings.python = config.settings.python or {}
						config.settings.python.pythonPath = util.get_python_path()
					end,
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "workspace",
								diagnosticSeverityOverrides = {
									reportGeneralTypeIssues = "none",
									reportOptionalMemberAccess = "none",
									reportAttributeAccessIssue = "none",
								},
							},
						},
					},
				})
				vim.lsp.enable("basedpyright")
			end

			-- Go
			if has("gopls") then
				vim.lsp.config("gopls", {
					filetypes = { "go" },
					settings = {
						gopls = {
							analyses = { unusedparams = true },
							staticcheck = true,
							gofumpt = true,
						},
					},
				})
				vim.lsp.enable("gopls")
			end

			-- Nix
			if has("nixd") then
				vim.lsp.config("nixd", {
					filetypes = { "nix" },
					settings = {
						nixd = {
							nixpkgs = {
								expr = "import <nixpkgs> {}",
							},
							formatting = {
								command = { "alejandra" },
							},
							diagnostic = {
								suppress = { "sema-escaping-with" },
							},
						},
					},
				})
				vim.lsp.enable("nixd")
			end

			-- Rust
			if has("rust-analyzer") then
				vim.lsp.config("rust_analyzer", {
					filetypes = { "rust" },
				})
				vim.lsp.enable("rust_analyzer")
			end

			-- TypeScript / JavaScript
			if has("typescript-language-server") then
				vim.lsp.config("ts_ls", {
					filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				})
				vim.lsp.enable("ts_ls")
			end

			-- Bash
			if has("bash-language-server") then
				vim.lsp.config("bashls", {
					filetypes = { "sh", "bash" },
				})
				vim.lsp.enable("bashls")
			end

			-- YAML
			if has("yaml-language-server") then
				vim.lsp.config("yamlls", {
					filetypes = { "yaml" },
				})
				vim.lsp.enable("yamlls")
			end

			-- Zig
			if has("zls") then
				vim.lsp.config("zls", {
					filetypes = { "zig" },
				})
				vim.lsp.enable("zls")
			end

			-- QML
			if has("qmlls") then
				vim.lsp.config("qmlls", {
					filetypes = { "qml" },
					cmd = { "qmlls", "-E" },
				})
				vim.lsp.enable("qmlls")
			end
		end,
	},
}
