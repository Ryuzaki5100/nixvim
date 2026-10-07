{
  pkgs,
  lspTools ? [ ],
  ...
}:
{
  extraPackages = lspTools;
  # Import all your configuration modules here
  imports = [
    ./../plugins
    ./bufferline.nix
    ./clangd.nix
    ./options.nix
    ./keymaps.nix
    ./custom-key-bindings.nix
  ];
}
