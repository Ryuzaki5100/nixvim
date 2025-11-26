# config/terminal.nix   (or any file that gets imported into your main config)

{
  plugins.toggleterm = {
    enable = true;

    settings = {
      direction = "float";

      float_opts = {
        border = "curved";
        height = 30;
        width = 130;
      };

      open_mapping = "[[<c-\\>]]";

      shell = "nix develop github:Ryuzaki5100/nixvim-dynamic -c $SHELL";

      # If you ever want the ultra-short local version instead, just comment the line above
      # and uncomment this one:
      # shell = "nix develop -c $SHELL";
    };
  };
}
