# nixvim-config/plugins/ui.nix
{ lib, ... }:
{
  # Force the default colorscheme so it wins over modules that set the option themselves
  colorscheme = lib.mkForce "base16-vesper";

  # Read colors.toml dynamically from omarchy at runtime to generate a colorscheme before plugins load
  extraConfigLua = ''
    local theme_file = vim.fn.expand("~/.config/omarchy/current/theme/colors.toml")
    local f = io.open(theme_file, "r")
    if f then
      local term_colors = {}
      for line in f:lines() do
        local k, v = line:match("([%w_]+)%s*=%s*\"(#%w+)\"")
        if k and v then
          term_colors[k] = v
        end
      end
      f:close()

      if term_colors.background then
        local b16 = {
          base00 = term_colors.background,
          base01 = term_colors.color0 or term_colors.background,
          base02 = term_colors.selection_background or term_colors.color8,
          base03 = term_colors.color8,
          base04 = term_colors.color7,
          base05 = term_colors.foreground or term_colors.color7,
          base06 = term_colors.color15,
          base07 = term_colors.color15,
          base08 = term_colors.color1,
          base09 = term_colors.color3,
          base0A = term_colors.color3,
          base0B = term_colors.color2,
          base0C = term_colors.color6,
          base0D = term_colors.color4,
          base0E = term_colors.color5,
          base0F = term_colors.color5
        }
        pcall(function()
          require("base16-colorscheme").setup(b16)
        end)
      end
    end
  '';

  plugins = {
    lualine.enable = true;

    lualine.settings = {
      options = {
        theme = "auto"; # follow whatever :colorscheme sets
        section_separators = "";
        component_separators = "";
      };
    };

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
