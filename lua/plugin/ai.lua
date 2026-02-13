local nixCats = require("nixCats")

return {
	-- 1. Register the dependency plugins so lze knows where they are in the nix store
	{ "nui.nvim", enabled = nixCats("avante") },
	{ "dressing.nvim", enabled = nixCats("avante") },
	{ "render-markdown.nvim", enabled = nixCats("avante") },

	-- 2. Avante Spec
	{
		"avante.nvim",
		enabled = nixCats("avante"),
		deferred = true,
		-- Reference the names registered above
		dep = { "nui-nvim", "dressing-nvim", "render-markdown-nvim" },
		after = function()
			require("avante").setup({
				provider = "copilot",
			})
		end,
	},

	-- 3. CodeCompanion Spec
	----{
	----	"codecompanion.nvim",
	----	enabled = nixCats("codecompanion"),
	----	deferred = true,
	----	after = function()
	----		require("codecompanion").setup({
	----			strategies = {
	----				chat = { adapter = "copilot" },
	----				inline = { adapter = "copilot" },
	----			},
	----		})
	----		-- Keybindings
	----		vim.keymap.set("n", "<leader>cc", function()
	----			require("codecompanion").chat.open()
	----		end, { desc = "CodeCompanion Chat" })
	----		vim.keymap.set("n", "<leader>ci", function()
	----			require("codecompanion").inline.suggest()
	----		end, { desc = "CodeCompanion Inline Suggest" })
	----		vim.keymap.set("n", "<leader>ca", function()
	----			require("codecompanion").inline.accept()
	----		end, { desc = "CodeCompanion Accept Suggestion" })
	----	end,
	----},
}
