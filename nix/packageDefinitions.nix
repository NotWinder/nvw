{inputs, ...}: {
  nvim = {pkgs, ...}: {
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
      completions = true;
      theme = true;
      avante = true;
    };
    extra = {
      nixdExtras = {nixpkgs = ''import ${pkgs.path} {}'';};
    };
  };
  nvim-cc = {pkgs, ...}: {
    settings = {
      wrapRc = true;
      aliases = ["cc"];
      neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    };
    categories = {
      general = true;
      lsps = true;
      format = true;
      complitions = true;
      theme = true;
      codecompanion = true;
    };
  };
}
