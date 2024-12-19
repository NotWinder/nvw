{
  globals = {
    mapleader = " ";
    netrw_browse_split = 0;
    netrw_banner = 0;
    netrw_winsize = 25;
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>pv";
      action = "<CMD>Oil<CR>";
    }

    {
      mode = "v";
      key = "J";
      action = ":m '>+1<CR>gv=gv";
    }

    {
      mode = "v";
      key = "K";
      action = ":m '<-2<CR>gv=gv";
    }

    {
      mode = "n";
      key = "J";
      action = "mzJ`z";
    }

    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
    }

    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
    }

    {
      mode = "n";
      key = "n";
      action = "nzzzv";
    }

    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
    }

    {
      mode = "i";
      key = "<C-c>";
      action = "<Esc>";
    }

    {
      mode = "n";
      key = "Q";
      action = "<nop>";
    }

    {
      mode = "n";
      key = "<C-f>";
      action = "<cmd>silent !tmux neww tmux-sessionizer<CR>";
    }

    {
      mode = "n";
      key = "<C-k>";
      action = "<cmd>cnext<CR>zz";
    }

    {
      mode = "n";
      key = "<C-j>";
      action = "<cmd>cprev<CR>zz";
    }

    {
      mode = "n";
      key = "<leader>k";
      action = "<cmd>lnext<CR>zz";
    }

    {
      mode = "n";
      key = "<leader>j";
      action = "<cmd>lprev<CR>zz";
    }

    {
      mode = "n";
      key = "<leader>x";
      action = "<cmd>!chmod +x %<CR>";
      options = {
        silent = true;
      };
    }

    {
      mode = "n";
      key = "<leader>mr";
      action = "<cmd>CellularAutomaton make_it_rain<CR>";
    }
  ];
  extraConfigLua = ''
    vim.keymap.set("x", "<leader>p", [["_dP]])

    vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
    vim.keymap.set("n", "<leader>Y", [["+Y]])

    vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

    vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

    vim.keymap.set("n", "<leader>vwm", function()
    	require("vim-with-me").StartVimWithMe()
    end)
    vim.keymap.set("n", "<leader>svwm", function()
    	require("vim-with-me").StopVimWithMe()
    end)
    vim.keymap.set("n", "<leader><leader>", function()
    	vim.cmd("so")
    end)
  '';
}
