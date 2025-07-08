{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      allowUnfree = true;
    };
    dependencyOverlays =
      /*
      (import ./overlays inputs) ++
      */
      [
        (utils.standardPluginOverlay inputs)
      ];

    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    } @ packageDef: {
      lspsAndRuntimeDeps = {
        general = with pkgs; [universal-ctags ripgrep fd];
        lsps = {
          go = with pkgs; [gccgo go-tools gofumpt golint gopls gotools];
          lua = with pkgs; [lua-language-server stylua];
          nix = with pkgs; [alejandra nix-doc nixd];
          bash = with pkgs; [bash-language-server];
          python = with pkgs; [black isort pyright];
          rust = with pkgs; [rust-analyzer];
          javascript = with pkgs; [typescript-language-server nodePackages.prettier];
          yaml = with pkgs; [yaml-language-server];
          zig = with pkgs; [zls];
        };
      };

      startupPlugins = {
        general = with pkgs.vimPlugins; {
          always = [lze lzextras nvim-web-devicons oil-nvim plenary-nvim];
          theme = with pkgs.vimPlugins; [catppuccin-nvim tokyonight-nvim];
        };
      };

      optionalPlugins = {
        #TODO: check this
        #lint = with pkgs.vimPlugins; [
        #  nvim-lint
        #];
        complitions = with pkgs.vimPlugins; [blink-cmp blink-compat cmp-cmdline colorful-menu-nvim luasnip];
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
      };
    };

    packageDefinitions = {
      nvim = {
        pkgs,
        name,
        ...
      }: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = true;
          aliases = ["vi" "vim"];
          neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
        };
        categories = {
          general = true;
          lsps = true;
          format = true;
          complitions = true;
          theme = true;
        };
        extra = {
          nixdExtras = {
            nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };
    };
    defaultPackageName = "nvim";
  in
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = utils.mkAllWithDefault defaultPackage;

      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
        };
      };
    })
    // (let
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };

      homeModule = utils.mkHomeModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
