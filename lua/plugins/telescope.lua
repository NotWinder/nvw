-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!

-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()
	if current_file == "" then
		current_dir = cwd
	else
		current_dir = vim.fn.fnamemodify(current_file, ":h")
	end

	local git_root =
		vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		print("Not a git repository. Searching on current working directory")
		return cwd
	end
	return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
	local git_root = find_git_root()
	if git_root then
		require("telescope.builtin").live_grep({
			search_dirs = { git_root },
		})
	end
end

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
		},
		cmd = { "Telescope", "LiveGrepGitRoot" },
		keys = {
			{ "<leader>pM", "<cmd>Telescope notify<CR>", desc = "[S]earch [M]essage" },
			{ "<leader>pp", live_grep_git_root, desc = "[S]earch git [P]roject root" },
			{
				"<leader>/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find(
						require("telescope.themes").get_dropdown({
							winblend = 10,
							previewer = false,
						})
					)
				end,
				desc = "[/] Fuzzily search in current buffer",
			},
			{
				"<leader>s/",
				function()
					require("telescope.builtin").live_grep({
						grep_open_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end,
				desc = "[S]earch [/] in Open Files",
			},
			{
				"<leader><leader>s",
				function()
					return require("telescope.builtin").buffers()
				end,
				desc = "[ ] Find existing buffers",
			},
			{
				"<leader>p.",
				function()
					return require("telescope.builtin").oldfiles()
				end,
				desc = '[S]earch Recent Files ("." for repeat)',
			},
			{
				"<leader>pr",
				function()
					return require("telescope.builtin").resume()
				end,
				desc = "[S]earch [R]esume",
			},
			{
				"<leader>pd",
				function()
					return require("telescope.builtin").diagnostics()
				end,
				desc = "[S]earch [D]iagnostics",
			},
			{
				"<leader>pg",
				function()
					return require("telescope.builtin").live_grep()
				end,
				desc = "[S]earch by [G]rep",
			},
			{
				"<leader>ps",
				function()
					return require("telescope.builtin").grep_string()
				end,
				desc = "[S]earch current [W]ord",
			},
			{
				"<leader>pw",
				function()
					return require("telescope.builtin").builtin()
				end,
				desc = "[S]earch [S]elect Telescope",
			},
			{
				"<leader>pf",
				function()
					return require("telescope.builtin").find_files()
				end,
				desc = "[S]earch [F]iles",
			},
			{
				"<leader>pk",
				function()
					return require("telescope.builtin").keymaps()
				end,
				desc = "[S]earch [K]eymaps",
			},
			{
				"<leader>vh",
				function()
					return require("telescope.builtin").help_tags()
				end,
				desc = "[S]earch [H]elp",
			},
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = { ["<c-enter>"] = "to_fuzzy_refine" },
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable telescope extensions, if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
		end,
	},
}
