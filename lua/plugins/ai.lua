return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		build = "make",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"stevearc/dressing.nvim",
			"MeanderingProgrammer/render-markdown.nvim",
		},
		opts = {
			provider = "copilot",
		},
	},
}
