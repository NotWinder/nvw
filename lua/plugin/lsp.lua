-- NOTE: This file uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- This is a slightly more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- nixCats gives us the paths, which is faster than searching the rtp!
local old_ft_fallback = require("lze").h.lsp.get_ft_fallback()
require("lze").h.lsp.set_ft_fallback(function(name)
	local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" })
		or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
	if lspcfg then
		local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
		if not ok then
			ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
		end
		return (ok and cfg or {}).filetypes or {}
	else
		return old_ft_fallback(name)
	end
end)

local function get_python_path()
	-- Check if we're in a virtualenv
	local venv = os.getenv("VIRTUAL_ENV")
	if venv then
		return venv .. "/bin/python"
	end

	-- Check common venv locations
	local cwd = vim.fn.getcwd()
	local venv_paths = {
		cwd .. "/.venv/bin/python",
		cwd .. "/venv/bin/python",
		cwd .. "/.virtualenv/bin/python",
	}

	for _, path in ipairs(venv_paths) do
		if vim.fn.executable(path) == 1 then
			return path
		end
	end

	return "python3" -- fallback
end

-- Enable diagnostics globally
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		header = "",
		prefix = "",
	},
})

-- Define diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

require("lze").load({
	{
		"nvim-lspconfig",
		for_cat = "general.core",
		on_require = { "lspconfig" },
		-- NOTE: define a function for lsp,
		-- and it will run for all specs with type(plugin.lsp) == table
		-- when their filetype trigger loads them
		lsp = function(plugin)
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
		before = function(_)
			-- Set global on_attach and handlers for all LSPs
			vim.lsp.config("*", {
				on_attach = require("plugin.on_attach"),
				handlers = {
					["textDocument/publishDiagnostics"] = vim.lsp.diagnostic.on_publish_diagnostics,
				},
			})
		end,
	},
	{
		-- lazydev makes your lsp way better in your config without needing extra lsp configuration.
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
	{
		-- name of the lsp
		"lua_ls",
		enabled = nixCats("lsps.lua") or false,
		lsp = {
			filetypes = { "lua" },
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					formatters = {
						ignoreComments = true,
					},
					signatureHelp = { enabled = true },
					diagnostics = {
						globals = { "nixCats", "vim" },
						disable = { "missing-fields" },
					},
					telemetry = { enabled = false },
				},
			},
		},
	},
	{
		"qmlls",
		enabled = nixCats("lsps.qml") or false,
		lsp = {
			filetypes = { "qml" },
			cmd = { "qmlls", "-E" },
		},
	},
	{
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
	},
	{
		"bashls",
		enabled = nixCats("lsps.bash") or false,
		lsp = {
			filetypes = { "bash" },
		},
	},
	{
		"basedpyright",
		enabled = nixCats("lsps.python") or false,
		lsp = {
			filetypes = { "python" },
			before_init = function(_, config)
				config.settings.python.pythonPath = get_python_path()
			end,
			on_attach = function(client, bufnr)
				require("plugin.on_attach")(client, bufnr)
			end,
			handlers = {
				["textDocument/publishDiagnostics"] = vim.lsp.diagnostic.on_publish_diagnostics,
			},
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
				python = {
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
		},
	},
	{
		"rust_analyzer",
		enabled = nixCats("lsps.rust") or false,
		lsp = {
			filetypes = { "rust" },
		},
	},
	{
		"ts_ls",
		enabled = nixCats("lsps.javascript") or false,
		lsp = {
			filetypes = { "js", "json", "ts" },
		},
	},
	{
		"yamlls",
		enabled = nixCats("lsps.yaml") or false,
		lsp = {
			filetypes = { "yaml" },
		},
	},
	{
		"zls",
		enabled = nixCats("lsps.zig") or false,
		lsp = {
			filetypes = { "zig" },
		},
	},
	{
		"nixd",
		enabled = nixCats("lsps.nix") or false,
		lsp = {
			filetypes = { "nix" },
			settings = {
				nixd = {
					nixpkgs = {
						expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
					},
					options = {
						nixos = {
							expr = nixCats.extra("nixdExtras.nixos_options"),
						},
						["home-manager"] = {
							expr = nixCats.extra("nixdExtras.home_manager_options"),
						},
					},
					formatting = {
						command = { "alejandra" },
					},
					diagnostic = {
						suppress = {
							"sema-escaping-with",
						},
					},
				},
			},
		},
	},
})
