{ ... }:
{
  plugins = {
    copilot-lua = {
      enable = false;
      settings = {
        suggestion = {
          enabled = false;
        };
        panel = {
          enabled = false;
        };
      };
    };

    copilot-cmp = {
      enable = true;
    };

    copilot-chat = {
      enable = true;
      settings = {
        chat = {
          enabled = true;
          #  Keep the layout to the right onto right of the screen completely and horizontal
          layout = "right";
        };
      };
    };
  };
}
