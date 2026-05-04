{ ... }:
{
  plugins = {
    cybu = {
      enable = true;
      settings = {
        position = {
          max_win_height = 30;
          max_win_width = 130;
        };
        style = {
          border = "rounded";
          padding = 5;
        };
        behaviour = {
          mode = {
            default = {
              switch = "on_close";
            };
          };
          show_on_autocmd = true;
        };
        display_time = 275;
      };
    };
  };
}
