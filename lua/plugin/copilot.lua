return {
	{
		"copilot.lua",
		for_cat = "completions",
		enabled = nixCats("completions") or false,
		cmd = "Copilot",
		event = "InsertEnter",
		after = function(_)
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<M-space>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
				},
			})
		end,
	},
}
