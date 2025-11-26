{ ... }:
{
  plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;

      settings = {
        snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

        sources = [
          { name = "nvim_lsp"; }
          {
            name = "luasnip";
            priority = 1000;
          }
          { name = "path"; }
          { name = "buffer"; }
        ];

        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-e>" = "cmp.mapping.abort()";

          "<Tab>" = /* lua */ ''
            function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end
          '';

          "<S-Tab>" = /* lua */ ''
            function(fallback)
              local luasnip = require("luasnip")
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end
          '';
        };
      };
    };

    cmp-nvim-lsp.enable = true;
    cmp-path.enable = true;
    cmp-buffer.enable = true;
    cmp_luasnip.enable = true;

    luasnip.enable = true;
    friendly-snippets.enable = true;

    lspkind.enable = true;
    lspkind.settings = {
      symbolMap = {
        Copilot = "?";
      };
      extraOptions = {
        maxwidth = 50;
      };
    };
  };
}
