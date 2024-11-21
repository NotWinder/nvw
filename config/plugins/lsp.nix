{
  plugins = {
    dap.enable = true;

    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        diagnostic = {
          "<leader>vd" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
          "<leader>vdo" = "setloclist";
        };
        lspBuf = {
          "K" = "hover";
          "gD" = "declaration";
          "gI" = "implementation";
          "gd" = "definition";
          "gy" = "type_definition";
          "<leader>gf" = "format";
          "<leader>vca" = "code_action";
          "<leader>vrn" = "rename";
          "<leader>vrr" = "references";
          "<leader>wa" = "add_workspace_folder";
          "<leader>wl" = "list_workspace_folders";
          "<leader>wr" = "remove_workspace_folder";
        };
      };
      preConfig = ''
        vim.diagnostic.config({
          virtual_text = false,
          severity_sort = true,
          float = {
            border = 'rounded',
            source = 'always',
          },
        })

        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
          vim.lsp.handlers.hover,
          {border = 'rounded'}
        )

        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
          vim.lsp.handlers.signature_help,
          {border = 'rounded'}
        )
      '';
      postConfig = ''
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
      '';
      servers = {
        #nil_ls.enable = true;
        bashls.enable = true;
        lua_ls.enable = true;
        nixd.enable = true;
        yamlls.enable = true;
      };
    };
  };
}
