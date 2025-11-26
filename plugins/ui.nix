# nixvim-config/plugins/ui.nix
{ ... }:
{
  plugins = {
    lualine.enable = true;

    neo-tree = {
      enable = true;
      closeIfLastWindow = true;
      popupBorderStyle = "rounded";
      enableGitStatus = true;
      enableDiagnostics = true;
    };

    which-key.enable = true;
    noice.enable = true;
    notify.enable = true;
    indent-blankline.enable = true;
    gitsigns.enable = true;
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
