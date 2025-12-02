{ ... }:
{
  plugins = {
    lsp = {
      enable = true;

      servers = {
        html.enable = true;
        cssls.enable = true;
        ts_query_ls.enable = true;
        gopls.enable = true;
        ccls.enable = true;
        jdtls.enable = true;
        marksman.enable = true; # Markdown
        nil_ls.enable = true; # Nix
        bashls.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        taplo.enable = true; # TOML
        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
          installRustfmt = true;
        };
      };

      keymaps = {
        diagnostic = {
          "<leader>cd" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };

        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "gi" = "implementation";
          "gt" = "type_definition";
          "<leader>cr" = "rename";
          "<leader>ca" = "code_action";
          "K" = "hover";
        };
      };
    };

    lspsaga.enable = true;
    lspsaga.settings = {
      beacon.enable = true;
      symbol_in_winbar.enable = true;
      lightbulb.enable = true;
    };

    trouble = {
      enable = true;
      settings.autoPreview = true;
    };

    lsp-format.enable = true;
  };

  keymaps = [
    {
      key = "<leader>cd";
      action = "<cmd>Trouble diagnostics toggle<CR>";
    }
    {
      key = "<leader>cs";
      action = "<cmd>Trouble symbols toggle<CR>";
    }
  ];
}
