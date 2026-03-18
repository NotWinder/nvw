-- nvim-treesitter (main branch, full rewrite)
-- The old nvim-treesitter.configs API is gone. Highlighting, indent, and
-- folding are now native Neovim features enabled via FileType autocmds.
-- nvim-treesitter-textobjects has its own setup and explicit keymap API.

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- plugin explicitly does not support lazy-loading
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			-- Install parsers (async; no-op if already installed)
			require("nvim-treesitter").install({
				"bash",
				"c",
				"css",
				"go",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"nix",
				"python",
				"rust",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
				"zig",
			})

			-- Enable treesitter highlighting for every buffer whose filetype has a parser.
			-- vim.treesitter.start() without a lang arg auto-detects from filetype.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("nvim_treesitter_highlight", { clear = true }),
				callback = function(ev)
					pcall(vim.treesitter.start, ev.buf)
				end,
			})

			-- ── nvim-treesitter-textobjects ──────────────────────────────────────
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local sel = require("nvim-treesitter-textobjects.select")
			local mov = require("nvim-treesitter-textobjects.move")
			local swp = require("nvim-treesitter-textobjects.swap")

			-- Text object select
			local select_map = {
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			}
			for key, query in pairs(select_map) do
				vim.keymap.set({ "x", "o" }, key, function()
					sel.select_textobject(query, "textobjects")
				end)
			end

			-- Move to next/previous function / class
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				mov.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "]]", function()
				mov.goto_next_start("@class.outer", "textobjects")
			end, { desc = "Next class start" })
			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				mov.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			vim.keymap.set({ "n", "x", "o" }, "][", function()
				mov.goto_next_end("@class.outer", "textobjects")
			end, { desc = "Next class end" })
			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				mov.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "[[", function()
				mov.goto_previous_start("@class.outer", "textobjects")
			end, { desc = "Prev class start" })
			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				mov.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Prev function end" })
			vim.keymap.set({ "n", "x", "o" }, "[]", function()
				mov.goto_previous_end("@class.outer", "textobjects")
			end, { desc = "Prev class end" })

			-- Swap parameters
			vim.keymap.set("n", "<leader>a", function()
				swp.swap_next("@parameter.inner", "textobjects")
			end, { desc = "Swap with next parameter" })
			vim.keymap.set("n", "<leader>A", function()
				swp.swap_previous("@parameter.inner", "textobjects")
			end, { desc = "Swap with prev parameter" })
		end,
	},
}
