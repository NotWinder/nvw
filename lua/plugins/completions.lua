return {
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
		lazy = true,
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local ls = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
			ls.config.setup({})

			vim.keymap.set({ "i", "s" }, "<M-n>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end)
		end,
	},
	{
		"saghen/blink.cmp",
		version = "1.*", -- pins to stable release with pre-built fuzzy binaries
		event = "VeryLazy",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"saghen/blink.compat",
			"hrsh7th/cmp-cmdline",
			"xzbdmw/colorful-menu.nvim",
		},
		config = function()
			require("blink.cmp").setup({
				keymap = {
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<C-k>"] = { "select_prev", "fallback_to_mappings" },
					["<C-j>"] = { "select_next", "fallback_to_mappings" },
					["<C-space>"] = { "select_and_accept" },
					["<C-e>"] = { "hide" },
					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },
				},
				cmdline = {
					enabled = true,
					completion = {
						menu = {
							auto_show = true,
						},
					},
					sources = function()
						local type = vim.fn.getcmdtype()
						-- Search forward and backward
						if type == "/" or type == "?" then
							return { "buffer" }
						end
						-- Commands
						if type == ":" or type == "@" then
							return { "cmdline", "cmp_cmdline" }
						end
						return {}
					end,
				},
				fuzzy = {
					sorts = {
						"exact",
						-- defaults
						"score",
						"sort_text",
					},
				},
				signature = {
					enabled = true,
					window = {
						show_documentation = true,
					},
				},
				completion = {
					menu = {
						draw = {
							treesitter = { "lsp" },
							components = {
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
							},
						},
					},
					documentation = {
						auto_show = true,
					},
				},
				snippets = {
					preset = "luasnip",
					active = function(filter)
						local snippet = require("luasnip")
						local blink = require("blink.cmp")
						if snippet.in_snippet() and not blink.is_visible() then
							return true
						else
							if not snippet.in_snippet() and vim.fn.mode() == "n" then
								snippet.unlink_current()
							end
							return false
						end
					end,
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer", "omni" },
					providers = {
						path = {
							score_offset = 50,
						},
						lsp = {
							score_offset = 40,
						},
						snippets = {
							score_offset = 40,
						},
						cmp_cmdline = {
							name = "cmp_cmdline",
							module = "blink.compat.source",
							score_offset = -100,
							opts = {
								cmp_name = "cmdline",
							},
						},
					},
				},
			})
		end,
	},
}
