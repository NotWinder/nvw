{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    nixvim,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: let
        nixvimLib = nixvim.lib.${system};
        nixvim' = nixvim.legacyPackages.${system};
        nixvimModule = {
          inherit pkgs;
          module = {
            imports = [
              ./config
              ./config/plugins
              ./config/plugins/lsp/go
              ./config/plugins/lsp/java
              ./config/plugins/lsp/js
              ./config/plugins/lsp/python
              ./config/plugins/lsp/zig
            ];
          };
        };
        goNixvimModule = {
          inherit pkgs;
          module = {
            imports = [
              ./config
              ./config/plugins
              ./config/plugins/lsp/go
            ];
          };
        };
        pythonNixvimModule = {
          inherit pkgs;
          module = {
            imports = [
              ./config
              ./config/plugins
              ./config/plugins/lsp/python
            ];
          };
        };
        javaNixvimModule = {
          inherit pkgs;
          module = {
            imports = [
              ./config
              ./config/plugins
              ./config/plugins/lsp/java
            ];
          };
        };
        javascriptNixvimModule = {
          inherit pkgs;
          module = {
            imports = [
              ./config
              ./config/plugins
              ./config/plugins/lsp/js
            ];
          };
        };
        zigNixvimModule = {
          inherit pkgs;
          module = {
            imports = [
              ./config
              ./config/plugins
              ./config/plugins/lsp/zig
            ];
          };
        };
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        nvim = nixvim'.makeNixvimWithModule nixvimModule;
        goNvim = nixvim'.makeNixvimWithModule goNixvimModule;
        pythonNvim = nixvim'.makeNixvimWithModule pythonNixvimModule;
        javascriptNvim = nixvim'.makeNixvimWithModule javascriptNixvimModule;
        javaNvim = nixvim'.makeNixvimWithModule javaNixvimModule;
        zigNvim = nixvim'.makeNixvimWithModule zigNixvimModule;
      in {
        checks = {
          # Run `nix flake check .` to verify that your config is not broken
          default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
          # Run `nix flake check .#go` to verify that your config is not broken
          go = nixvimLib.check.mkTestDerivationFromNixvimModule goNixvimModule;
          # Run `nix flake check .#js` to verify that your config is not broken
          js = nixvimLib.check.mkTestDerivationFromNixvimModule javascriptNixvimModule;
          # Run `nix flake check .python` to verify that your config is not broken
          python = nixvimLib.check.mkTestDerivationFromNixvimModule pythonNixvimModule;
          # Run `nix flake check .#java` to verify that your config is not broken
          java = nixvimLib.check.mkTestDerivationFromNixvimModule javaNixvimModule;
          # Run `nix flake check .#zig` to verify that your config is not broken
          zig = nixvimLib.check.mkTestDerivationFromNixvimModule zigNixvimModule;
        };

        packages = {
          # Lets you run `nix run .` to start nixvim with all the configs avalable
          default = nvim;
          # Lets you run `nix run .#go` to start nixvim with Go configuration
          go = goNvim;
          # Lets you run `nix run .#python` to start nixvim with Python configuration
          python = pythonNvim;
          # Lets you run `nix run .#js` to start nixvim with JS/TS configuration
          js = javascriptNvim;
          # Lets you run `nix run .#java` to start nixvim with JS/TS configuration
          java = javaNvim;
          # Lets you run `nix run .#zig` to start nixvim with JS/TS configuration
          zig = zigNvim;
        };
      };
    };
}
