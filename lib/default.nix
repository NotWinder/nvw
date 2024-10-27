{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {
  mkVimPlugin = {system}: let
    inherit (pkgs) vimUtils;
    inherit (vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
  in
    buildVimPlugin {
      name = "winder";
      postInstall = ''
        rm -rf $out/.envrc
        rm -rf $out/.gitignore
        rm -rf $out/LICENSE
        rm -rf $out/README.md
        rm -rf $out/flake.lock
        rm -rf $out/flake.nix
        rm -rf $out/justfile
        rm -rf $out/lib
      '';
      src = ../.;
    };

  mkNeovimPlugins = {system}: let
    inherit (pkgs) vimPlugins;
    pkgs = legacyPackages.${system};
    winder-nvim = mkVimPlugin {inherit system;};
  in [
    # lsp-config
    vimPlugins.zig-vim

    #LSP-config
    vimPlugins.mason-nvim
    vimPlugins.mason-lspconfig-nvim
    vimPlugins.nvim-lspconfig

    # telescope
    vimPlugins.plenary-nvim
    vimPlugins.telescope-nvim
    vimPlugins.telescope-ui-select-nvim

    # theme
    vimPlugins.tokyonight-nvim

    # formatter
    vimPlugins.none-ls-nvim

    # extras
    vimPlugins.comment-nvim
    vimPlugins.lualine-nvim
    vimPlugins.harpoon
    vimPlugins.undotree
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.vim-just
    vimPlugins.lazydev-nvim

    #CMP
    vimPlugins.nvim-cmp
    vimPlugins.luasnip
    vimPlugins.cmp_luasnip
    vimPlugins.friendly-snippets
    vimPlugins.cmp-nvim-lsp

    # configuration
    winder-nvim
  ];

  mkExtraPackages = {system}: let
    inherit (pkgs) nodePackages python3Packages;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in [
    # language servers
    nodePackages.bash-language-server
    nodePackages.diagnostic-languageserver
    nodePackages.typescript-language-server
    nodePackages.yaml-language-server
    pkgs.gopls
    pkgs.jsonnet-language-server
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.pyright
    pkgs.rust-analyzer
    pkgs.zls

    # formatters
    nodePackages.prettier
    pkgs.alejandra
    pkgs.gofumpt
    pkgs.golines
    pkgs.isort
    pkgs.revive
    pkgs.stylua
    python3Packages.black

    #Extra
    pkgs.git
    pkgs.zig
  ];

  mkExtraConfig = ''
    lua << EOF
      require('winder')
    EOF
  '';

  mkNeovim = {system}: let
    inherit (pkgs) lib neovim;
    extraPackages = mkExtraPackages {inherit system;};
    pkgs = legacyPackages.${system};
    start = mkNeovimPlugins {inherit system;};
  in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {inherit start;};
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager = {system}: let
    extraConfig = mkExtraConfig;
    extraPackages = mkExtraPackages {inherit system;};
    plugins = mkNeovimPlugins {inherit system;};
  in {
    inherit extraConfig extraPackages plugins;
    defaultEditor = true;
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
