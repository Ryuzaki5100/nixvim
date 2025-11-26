# nixvim-config/plugins/java.nix
{ pkgs, ... }: {
  plugins = {
    neotest = {
      enable = true;
    };

    conform-nvim = {
      enable = true;
      settings = {
        formatOnSave = {
        timeoutMs = 3000;
        lspFallback = true;
        };
      formattersByFt = {
        java = [ "google_java_format" ];
        };
      };
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-jdtls
  ];
}
