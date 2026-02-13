{
  pkgs,
  settings,
  categories,
  extra,
  name,
  mkPlugin,
  ...
} @ packageDef: {
  lspsAndRuntimeDeps = {
    general = with pkgs; [universal-ctags ripgrep fd nodejs_24];
    lsps = {
      go = with pkgs; [gccgo go-tools gofumpt golint gopls gotools];
      lua = with pkgs; [lua-language-server stylua];
      nix = with pkgs; [alejandra nix-doc nixd];
      bash = with pkgs; [bash-language-server];
      python = with pkgs; [basedpyright ruff python313Packages.django-stubs];
      rust = with pkgs; [rust-analyzer];
      qml = with pkgs; [kdePackages.qtdeclarative];
      javascript = with pkgs; [typescript-language-server nodePackages.prettier];
      yaml = with pkgs; [yaml-language-server];
      zig = with pkgs; [zls];
    };
  };

  startupPlugins = {
    general = with pkgs.vimPlugins; {
      always = [lze lzextras nvim-web-devicons oil-nvim plenary-nvim];
      theme = [catppuccin-nvim tokyonight-nvim];
    };
  };

  optionalPlugins = {
    complitions = with pkgs.vimPlugins; [blink-cmp blink-compat cmp-cmdline colorful-menu-nvim luasnip copilot-lua];
    format = with pkgs.vimPlugins; [conform-nvim];
    lsps = {
      core = with pkgs.vimPlugins; [nvim-lspconfig];
      lua = with pkgs.vimPlugins; [lazydev-nvim];
    };
    general = {
      always = with pkgs.vimPlugins; [gitsigns-nvim nvim-surround undotree];
      telescope = with pkgs.vimPlugins; [telescope-fzf-native-nvim telescope-nvim telescope-ui-select-nvim];
      theme = with pkgs.vimPlugins; [fidget-nvim lualine-lsp-progress lualine-nvim which-key-nvim];
      treesitter = with pkgs.vimPlugins; [nvim-treesitter-textobjects nvim-treesitter.withAllGrammars];
      markdown = with pkgs.vimPlugins; [markdown-preview-nvim];
    };

    # Add these two new categories
    avante = with pkgs.vimPlugins; [
      avante-nvim
      dressing-nvim
      nui-nvim
      render-markdown-nvim
    ];

    codecompanion = with pkgs.vimPlugins; [
      codecompanion-nvim
    ];
  };
}
