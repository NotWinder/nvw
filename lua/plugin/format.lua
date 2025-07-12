return {
	{
		"conform.nvim",
		for_cat = "format",
		keys = {
			{ "<leader>ff", desc = "[F]ormat [F]ile" },
		},
		after = function(plugin)
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					go = { "gofmt", "golint" },
					javascript = { "prettier" },
					json = { "prettier" },
					lua = { "stylua" },
					nix = { "alejandra" },
					python = { "isort", "black" },
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>ff", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "[F]ormat [F]ile" })

			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					conform.format({ bufnr = args.buf })
				end,
			})
		end,
	},
}
