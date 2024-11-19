{
  plugins = {
    web-devicons.enable = true;
    telescope = {
      enable = true;
      keymaps = {
        "<leader>pf" = {
          action = "find_files";
          options = {
            desc = "Telescope all Files";
          };
        };
        "<C-p>" = {
          action = "git_files";
          options = {
            desc = "Telescope Git Files";
          };
        };
        "<leader>pws" = {
          action = ''
            function()
                local word = vim.fn.expand("<cword>")
                builtin.grep_string({ search = word })
            end)
          '';
          options = {
            desc = "Telescope a word in Files";
          };
        };
        "<leader>pWs" = {
          action = ''
            function()
                local word = vim.fn.expand("<cWORD>")
                builtin.grep_string({ search = word })
            end)
          '';
          options = {
            desc = "Telescope a word(until whitespaces) in Files";
          };
        };
        "<leader>ps" = {
          action = "live_grep";

          options = {
            desc = "live greps in all the files";
          };
        };
        "<leader>vh" = {
          action = "help_tags";

          options = {
            desc = "shows the help tags";
          };
        };
      };
      extensions = {
        fzf-native = {
          enable = true;
        };
        fzy-native = {
          enable = true;
        };
        ui-select = {
          enable = true;
        };
      };
    };
  };
}
