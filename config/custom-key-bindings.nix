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
      key = "<leader>h";
      action = "<Esc>:Neotree<CR>";
      mode = "n";
      options = {
        desc = "Toggle File Explorer";
      };
    }
    {
      key = "<leader>b";
      action = "<Esc>:color ";
      mode = "n";
      options = {
        desc = "Change Background color";
      };
    }
  ];
}
