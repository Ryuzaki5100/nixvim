{
  keymaps = [
    # My Custom Key-Bindings
    {
      key = "jl";
      action = "<Esc>:";
      mode = "i";
      options = {
        desc = "Enter Command-line Mode from Insert Mode";
      };
    }
    {
      key = "kj";
      action = "<Esc>:w<CR>";
      mode = "i";
      options = {
        silent = true;
        desc = "Save File from Insert Mode";
      };
    }
    {
      key = "jk";
      action = "<Esc>";
      mode = "i";
      options = {
        silent = true;
        desc = "Enter Normal Mode from Insert Mode";
      };
    }
    {
      key = "jk";
      action = "<C-\\><C-n>";
      mode = "t";
      options = {
        desc = "Exit Terminal Mode";
      };
    }
    {
      key = "jl";
      action = "<C-\\><C-n>:";
      mode = "t";
      options = {
        desc = "Open Command-line";
      };
    }
    {
      key = "<leader>h";
      action = "<Esc>:Neotree<CR>";
      mode = "n";
      options = {
        silent = true;
        desc = "Toggle File Explorer";
      };
    }
    {
      key = "<leader>b";
      action = "<Esc>:color base16-";
      mode = "n";
      options = {
        desc = "Change Base16 Background color";
      };
    }
    {
      key = "<Tab>";
      action = ":CybuLastusedNext<CR>";
      mode = "n";
      options = {
        silent = true;
        desc = "Go to next buffer";
      };
    }
    {
      key = "<S-Tab>";
      action = ":CybuLastusedPrev<CR>";
      mode = "n";
      options = {
        silent = true;
        desc = "Go to previous buffer";
      };
    }
    {
      key = "H";
      action = "^";
      mode = "n";
      options = {
        silent = true;
        desc = "Go to first character of a line";
      };
    }
    {
      key = "L";
      action = "$";
      mode = "n";
      options = {
        silent = true;
        desc = "Go to last character of a line";
      };
    }
  ];
}
