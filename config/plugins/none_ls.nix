{
  plugins = {
    none-ls = {
      enable = true;
      sources.formatting = {
        alejandra.enable = true;
        black.enable = true;
        gofumpt.enable = true;
        golines.enable = true;
        isort.enable = true;
        prettier = {
          enable = true;
          disableTsServerFormatter = true;
        };
        sqlformat.enable = true;
        stylua.enable = true;
        yamlfmt.enable = true;
      };
      sources.diagnostics = {
        revive.enable = true;
        yamllint.enable = true;
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_fallback = "fallback";
          timeout_ms = 500;
        };
        notify_on_error = true;

        formatters_by_ft = {
          css = ["prettier"];
          html = ["prettier"];
          json = ["prettier"];
          lua = ["stylua"];
          markdown = ["prettier"];
          nix = ["alejandra"];
          yaml = ["yamlfmt"];
        };
      };
    };
  };
}