local nixCats = require("nixCats")

return {
	-- 1. Register the dependency plugins so lze knows where they are in the nix store
	-- These plugins are only enabled if the "avante" category is active in nixCats
	{ "nui.nvim", enabled = nixCats("avante") },
	{ "dressing.nvim", enabled = nixCats("avante") },
	{ "render-markdown.nvim", enabled = nixCats("avante") },

	-- 2. Avante Spec
	-- This plugin provides advanced AI capabilities integrated with Copilot
	{
		"avante.nvim",
		enabled = nixCats("avante"),
		deferred = true,
		-- Reference the names registered above as dependencies
		dep = { "nui-nvim", "dressing-nvim", "render-markdown-nvim" },
		after = function()
			require("avante").setup({
				provider = "copilot", -- Use Copilot as the AI provider
			})
		end,
	},

	-- 3. CodeCompanion Spec
	-- (Currently commented out) Provides additional AI integration for chat and inline suggestions
	-- Uncomment and enable if "codecompanion" is needed
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
	----		-- Keybindings for CodeCompanion features
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
