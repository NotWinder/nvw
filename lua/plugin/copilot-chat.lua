return {
	{
		"CopilotChat.nvim",
		for_cat = "complitions",
		cmd = {
			"CopilotChat",
			"CopilotChatOpen",
			"CopilotChatClose",
			"CopilotChatToggle",
			"CopilotChatExplain",
			"CopilotChatReview",
			"CopilotChatFix",
			"CopilotChatOptimize",
			"CopilotChatDocs",
			"CopilotChatTests",
		},
		keys = {
			{ "<leader>cc", desc = "[C]opilot [C]hat Toggle" },
			{ "<leader>ce", desc = "[C]opilot [E]xplain", mode = { "n", "v" } },
			{ "<leader>cfc", desc = "[C]opilot [F]ile [C]ontext", mode = { "n", "v" } },
			{ "<leader>cdc", desc = "[C]opilot [D]irectory [C]ontext", mode = { "n", "v" } },
			{ "<leader>cpc", desc = "[C]opilot [P]roject [C]ontext", mode = { "n", "v" } },
		},
		on_require = { "CopilotChat" },
		after = function(_)
			local chat = require("CopilotChat")
			chat.setup({
				model = "claude-opus-4.5",
				temperature = 0.1,
				window = {
					layout = "vertical",
					width = 0.5,
				},
				auto_insert_mode = true,
			})

			local ignore_dirs =
				{ ".git", "node_modules", ".venv", "venv", "dist", "build", "target", "__pycache__", ".cache" }
			local allowed_ext = {
				".lua",
				".py",
				".ts",
				".js",
				".jsx",
				".tsx",
				".go",
				".rs",
				".java",
				".c",
				".cpp",
				".h",
				".json",
				".yaml",
				".yml",
				".toml",
				".md",
				".env",
				".sh",
				"Dockerfile",
			}

			local function is_ignored(path)
				for _, dir in ipairs(ignore_dirs) do
					if path:find("/" .. dir .. "/") then
						return true
					end
				end
				return false
			end

			local function has_allowed_ext(path)
				for _, ext in ipairs(allowed_ext) do
					if path:sub(-#ext) == ext then
						return true
					end
				end
				return false
			end

			local function scan_dir(dir, files)
				files = files or {}
				for name, type in vim.fs.dir(dir) do
					local full_path = dir .. "/" .. name
					if type == "directory" then
						if not is_ignored(full_path) then
							scan_dir(full_path, files)
						end
					elseif type == "file" and has_allowed_ext(full_path) then
						table.insert(files, full_path)
					end
				end
				return files
			end

			-- Helper to format scanned files into a single string
			local function get_formatted_context(files)
				local content = {}
				for _, file in ipairs(files) do
					local ok, lines = pcall(vim.fn.readfile, file)
					if ok then
						table.insert(content, "\n\n### FILE: " .. file .. "\n")
						table.insert(content, table.concat(lines, "\n"))
					end
				end
				return table.concat(content, "\n")
			end

			-- Context Grabbers
			local function get_file_context()
				return get_formatted_context({ vim.fn.expand("%:p") })
			end

			local function get_directory_context()
				local dir = vim.fn.expand("%:p:h")
				return get_formatted_context(scan_dir(dir))
			end

			local function get_project_context()
				return get_formatted_context(scan_dir(vim.fn.getcwd()))
			end

			-- Generic Chat Function
			local select = require("CopilotChat.select")
			local function ask_with_custom_context(prompt, context_func)
				local context = context_func()
				chat.ask(prompt .. "\n\nRelevant Context:\n" .. context, { selection = select.visual })
			end

			-- Keybindings
			vim.keymap.set("n", "<leader>cc", chat.toggle, { desc = "Toggle Chat" })

			-- Current File Context
			vim.keymap.set({ "n", "v" }, "<leader>cfc", function()
				local input = vim.fn.input("File Context Prompt: ")
				if input ~= "" then
					ask_with_custom_context(input, get_file_context)
				end
			end, { desc = "[C]opilot [F]ile [C]ontext" })

			-- Current Directory Context
			vim.keymap.set({ "n", "v" }, "<leader>cdc", function()
				local input = vim.fn.input("Directory Context Prompt: ")
				if input ~= "" then
					ask_with_custom_context(input, get_directory_context)
				end
			end, { desc = "[C]opilot [D]irectory [C]ontext" })

			-- Whole Project Context
			vim.keymap.set({ "n", "v" }, "<leader>cpc", function()
				local input = vim.fn.input("Project Context Prompt: ")
				if input ~= "" then
					ask_with_custom_context(input, get_project_context)
				end
			end, { desc = "[C]opilot [P]roject [C]ontext" })
		end,
	},
}
