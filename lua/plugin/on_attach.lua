return function(_, bufnr)
	-- Debug: print when attached
	-- print("LSP attached: " .. client.name)

	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>vrn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>vca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

	if nixCats("general.telescope") then
		nmap("gr", function()
			require("telescope.builtin").lsp_references()
		end, "[G]oto [R]eferences")
		nmap("gI", function()
			require("telescope.builtin").lsp_implementations()
		end, "[G]oto [I]mplementation")
		nmap("<leader>ds", function()
			require("telescope.builtin").lsp_document_symbols()
		end, "[D]ocument [S]ymbols")
		nmap("<leader>ws", function()
			require("telescope.builtin").lsp_dynamic_workspace_symbols()
		end, "[W]orkspace [S]ymbols")
	end

	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("<leader>vwa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>vwr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")

	nmap("<leader>vd", function()
		local diags = vim.diagnostic.get(bufnr, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
		if #diags == 0 then
			print("No diagnostics on this line")
		else
			vim.diagnostic.open_float()
		end
	end, "[V]iew [d]iagnostic")

	nmap("<leader>vrr", vim.lsp.buf.references, "[V]iew [r]eferences")

	-- FIXED: Wrap in functions
	nmap("[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, "Previous diagnostic")

	nmap("]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, "Next diagnostic")

	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end
