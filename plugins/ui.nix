# nixvim-config/plugins/ui.nix
{ lib, ... }:
{
  # Force the default colorscheme so it wins over modules that set the option themselves
  colorscheme = lib.mkForce "gruvbox-material";

  plugins = {
    lualine.enable = true;

    neo-tree.enable = true;

    neo-tree.settings = {
      close_if_last_window = true;
      popup_border_style = "rounded";
      enable_git_status = true;
      enable_diagnostics = true;
    };

    which-key.enable = true;
    noice.enable = true;
    notify.enable = true;

    gitsigns.enable = true;

    indent-blankline = {
      enable = true;
      settings = {
        scope = {
          enabled = true;
          show_start = true;
        };
      };
    };
  };

  # Enable all themes so you can switch with :colorscheme <name>
  colorschemes.ayu = {
    enable = true;
  };
  colorschemes.bamboo = {
    enable = true;
  };
  colorschemes.base16 = {
    enable = true;
  };
  colorschemes.catppuccin = {
    enable = true;
  };
  colorschemes.cyberdream = {
    enable = true;
  };
  colorschemes.dracula = {
    enable = true;
  };
  colorschemes.dracula-nvim = {
    enable = true;
  };
  colorschemes.everforest = {
    enable = true;
  };
  colorschemes.github-theme = {
    enable = true;
  };
  colorschemes.gruvbox = {
    enable = true;
  };
  colorschemes.gruvbox-baby = {
    enable = true;
  };
  colorschemes.gruvbox-material = {
    enable = true;
    settings.transparent_background = 2;
  };
  colorschemes.gruvbox-material-nvim = {
    enable = true;
  };
  colorschemes.kanagawa = {
    enable = true;
  };
  colorschemes.kanagawa-paper = {
    enable = true;
  };
  colorschemes.melange = {
    enable = true;
  };
  colorschemes.modus = {
    enable = true;
  };
  colorschemes.monokai-pro = {
    enable = true;
  };
  colorschemes.moonfly = {
    enable = true;
  };
  colorschemes.nightfox = {
    enable = true;
  };
  colorschemes.nord = {
    enable = true;
  };
  colorschemes.one = {
    enable = true;
  };
  colorschemes.onedark = {
    enable = true;
  };
  colorschemes.oxocarbon = {
    enable = true;
  };
  colorschemes.palette = {
    enable = true;
  };
  colorschemes.poimandres = {
    enable = true;
  };
  colorschemes.rose-pine = {
    enable = true;
  };
  colorschemes.solarized-osaka = {
    enable = true;
  };
  colorschemes.tokyonight = {
    enable = true;
  };
  colorschemes.vague = {
    enable = true;
  };
  colorschemes.vscode = {
    enable = true;
  };

  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
    }
  ];
}
