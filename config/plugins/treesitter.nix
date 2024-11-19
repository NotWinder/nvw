{
  plugins.treesitter = {
    enable = true;
    settings = {
      ensure_installed = [
        "bash"
        "c"
        "javascript"
        "jsdoc"
        "lua"
        "rust"
        "typescript"
        "vimdoc"
      ];
      auto_install = true;

      indent = {
        enable = true;
      };
      highlight = {
        enable = true;
      };
    };
  };
}
