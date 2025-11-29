# nixvim-config/plugins/ui.nix
{ ... }:
{
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

  colorschemes.gruvbox-material = {
    enable = true;
    settings.transparent_background = 2;
  };

  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
    }
  ];
}
