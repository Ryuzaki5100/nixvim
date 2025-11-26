{
  keymaps = [
    # Close current buffer (does NOT quit Neovim)
    {
      key = "<leader>c";
      action = "<cmd>bdelete<CR>";
      options.desc = "Close buffer";
    }
    {
      key = "<leader>x";
      action = "<cmd>x<CR>";
      options.desc = "Save & close buffer";
    }

    # Close all other buffers except current
    {
      key = "<leader>o";
      action = "<cmd>%bd|e#|bd#<CR>";
      options.desc = "Close others";
    }
  ];
}
