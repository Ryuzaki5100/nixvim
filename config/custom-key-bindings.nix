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

  ];
}
