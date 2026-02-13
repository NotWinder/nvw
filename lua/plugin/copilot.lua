return {
	{
		"copilot.lua",
		for_cat = "completions",  -- corrected typo in category name
		cmd = "Copilot",
		event = "InsertEnter",
		-- Ensure proper dependency handling
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
