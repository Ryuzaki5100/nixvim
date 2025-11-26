{ ... }:
{
  plugins.telescope = {
    enable = true;
    extensions = {
      fzf-native.enable = true;
      ui-select.enable = true;
    };
  };

  keymaps = [
    {
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
    }
    {
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<CR>";
    }
    {
      key = "<leader>fb";
      action = "<cmd>Telescope buffers<CR>";
    }
    {
      key = "<leader>fh";
      action = "<cmd>Telescope help_tags<CR>";
    }
    {
      key = "<leader>fr";
      action = "<cmd>Telescope lsp_references<CR>";
    }
    {
      key = "<leader>fs";
      action = "<cmd>Telescope lsp_document_symbols<CR>";
    }
  ];
}
