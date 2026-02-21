-- LSP Capabilities configuration
-- Builds client capabilities with support for blink.cmp and optional folding
local M = {}

---@return lsp.ClientCapabilities
function M.make()
	local capabilities = vim.lsp.protocol.make_client_capabilities()

	-- Add blink.cmp capabilities if available
	local ok, blink = pcall(require, "blink.cmp")
	if ok then
		local blink_caps = blink.get_lsp_capabilities()
		if blink_caps then
			capabilities = vim.tbl_deep_extend("force", capabilities, blink_caps)
		end
	end

	-- Add folding capabilities (for nvim-ufo or native folding)
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	return capabilities
end

return M
