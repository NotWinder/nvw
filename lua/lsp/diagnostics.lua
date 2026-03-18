-- LSP Diagnostics configuration
-- Sets up diagnostic display and signs
local M = {}

function M.setup()
	-- Configure diagnostic display (signs.text is the Neovim 0.10+ API;
	-- vim.fn.sign_define for diagnostic signs is deprecated)
	vim.diagnostic.config({
		virtual_text = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			header = "",
			prefix = "",
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
				[vim.diagnostic.severity.INFO] = " ",
			},
		},
	})
end

return M
