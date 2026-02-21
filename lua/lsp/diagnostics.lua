-- LSP Diagnostics configuration
-- Sets up diagnostic display and signs
local M = {}

function M.setup()
	-- Configure diagnostic display
	vim.diagnostic.config({
		virtual_text = true,
		signs = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			header = "",
			prefix = "",
		},
	})

	-- Define diagnostic signs with icons
	local signs = {
		Error = "󰅚 ",
		Warn = "󰀪 ",
		Hint = "󰌶 ",
		Info = " ",
	}

	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end
end

return M
