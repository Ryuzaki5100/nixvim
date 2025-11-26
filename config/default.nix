{pkgs, lspTools ? [], ... }:
{
  extraPackages = lspTools;
  # Import all your configuration modules here
  imports = [
    ./../plugins
    ./bufferline.nix
    ./options.nix
    ./keymaps.nix
  ];
}
