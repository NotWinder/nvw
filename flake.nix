{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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
    extra_pkg_config = {allowUnfree = true;};

    dependencyOverlays = [(utils.standardPluginOverlay inputs)];

    categoryDefinitions = import ./nix/categoryDefinitions.nix;
    packageDefinitions = import ./nix/packageDefinitions.nix {inherit inputs;};

    defaultPackageName = "nvim";
  in
    forEachSystem (
      system: let
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
        devShells.default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
        };
      }
    )
    // (
      # The rest of your module logic stays here or can be modularized further
      let
        moduleArgs = {
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

        nixosModules.default = utils.mkNixosModules (moduleArgs // {moduleNamespace = [defaultPackageName];});
        homeModules.default = utils.mkHomeModules (moduleArgs // {moduleNamespace = [defaultPackageName];});

        inherit utils;
        inherit (utils) templates;
      }
    );
}
