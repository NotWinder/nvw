require("tokyonight").setup({
	style = "storm",
	transparent = true,
})
require("tokyonight").load()
return {
	{
		"lualine.nvim",
		for_cat = "general.always",
		enabled = nixCats("general.always") or false,
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = {},
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					globalstatus = false,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {
					lualine_a = { "buffers" },
					lualine_b = { "lsp_progress" },
					lualine_z = { "tabs" },
				},
			})
		end,
	},
	{
		"fidget.nvim",
		for_cat = "general.extra",
		enabled = nixCats("general.extra") or false,
		event = "DeferredUIEnter",
		after = function(plugin)
			require("fidget").setup({})
		end,
	},
	{
		"which-key.nvim",
		for_cat = "general.extra",
		enabled = nixCats("general.extra") or false,
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("which-key").setup({})
			require("which-key").add({
				{ "<leader><leader>", group = "buffer commands" },
				{ "<leader><leader>_", hidden = true },
				{ "<leader>c", group = "[c]ode" },
				{ "<leader>c_", hidden = true },
				{ "<leader>d", group = "[d]ocument" },
				{ "<leader>d_", hidden = true },
				{ "<leader>g", group = "[g]it" },
				{ "<leader>g_", hidden = true },
				{ "<leader>m", group = "[m]arkdown" },
				{ "<leader>m_", hidden = true },
				{ "<leader>r", group = "[r]ename" },
				{ "<leader>r_", hidden = true },
				{ "<leader>s", group = "[s]earch" },
				{ "<leader>s_", hidden = true },
				{ "<leader>t", group = "[t]oggles" },
				{ "<leader>t_", hidden = true },
				{ "<leader>w", group = "[w]orkspace" },
				{ "<leader>w_", hidden = true },
			})
		end,
	},
}
