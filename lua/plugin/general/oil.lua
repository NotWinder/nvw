vim.g.loaded_netrwPlugin = 1
-- Configure Oil plugin for file management
require("oil").setup({
	default_file_explorer = true, -- Use Oil as the default file explorer
	view_options = {
		show_hidden = true, -- Show hidden files by default
	},
	columns = {
		"icon", -- Display file icons
		"permissions", -- Show file permissions
		"size", -- Display file sizes
		-- "mtime", -- Uncomment to show modification times
	},
	keymaps = {
		["g?"] = "actions.show_help", -- Show help
		["<CR>"] = "actions.select", -- Select file or directory
		["<C-s>"] = "actions.select_vsplit", -- Open in vertical split
		["<C-h>"] = "actions.select_split", -- Open in horizontal split
		["<C-t>"] = "actions.select_tab", -- Open in new tab
		["<C-p>"] = "actions.preview", -- Preview file
		["<C-c>"] = "actions.close", -- Close Oil
		["<C-l>"] = "actions.refresh", -- Refresh Oil view
		["-"] = "actions.parent", -- Go to parent directory
		["_"] = "actions.open_cwd", -- Open current working directory
		["`"] = "actions.cd", -- Change directory to selected
		["~"] = "actions.tcd", -- Change directory globally
		["gs"] = "actions.change_sort", -- Change sort order
		["gx"] = "actions.open_external", -- Open file externally
		["g."] = "actions.toggle_hidden", -- Toggle hidden files
		["g\\"] = "actions.toggle_trash", -- Toggle trash visibility
	},
})
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, desc = "Open Parent Directory" })
vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true, desc = "Open nvim root directory" })
