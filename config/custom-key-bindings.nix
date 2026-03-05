{
  keymaps = [
    # My Custom Key-Bindings
    # Exiting out of insert mode using jk
    {
      key = "jk";
      action = "<Esc>";
      mode = "i";
      options = {
        silent = true;
        desc = "Escape to Normal Mode";
      };
    }
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
        desc = "Save File from Insert Mode";
      };
    }

  ];
}
