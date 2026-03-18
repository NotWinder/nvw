return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>ff",
				function()
			require("conform").format({
					lsp_format = "fallback",
					async = false,
					timeout_ms = 1000,
					})
				end,
				mode = { "n", "v" },
				desc = "[F]ormat [F]ile",
			},
		},
		opts = {
			formatters_by_ft = {
				go = { "gofmt" },
				javascript = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
				nix = { "alejandra" },
				python = { "ruff_format" },
			},
			format_on_save = {
				lsp_format = "fallback",
				timeout_ms = 1000,
			},
		},
	},
}
