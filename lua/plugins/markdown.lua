return {
	{
		"iamcco/markdown-preview.nvim",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		ft = "markdown",
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "markdown preview" },
			{ "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "markdown preview stop" },
			{ "<leader>mt", "<cmd>MarkdownPreviewToggle<CR>", desc = "markdown preview toggle" },
		},
		init = function()
			vim.g.mkdp_auto_close = 0
		end,
	},
}
