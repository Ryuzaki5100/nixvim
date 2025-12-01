# nixvim-config/options.nix
{ ... }: {
  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    # === Cursor wobble fix (THE TWO LINES YOU NEED) ===
    signcolumn = "yes"; # always reserve space for signs → no left/right wobble
    foldcolumn = "0"; # hide fold column → cleaner look

    # === Folding (files open completely unfolded) ===
    foldlevelstart = 99; # start with everything open
    foldenable = false; # (optional) completely disables initial folding

    # === Your usual preferences ===
    number = true;
    relativenumber = true;
    shiftwidth = 4;
    tabstop = 4;
    expandtab = true;
    cursorline = true;
    termguicolors = true;
    mouse = "a";
    autoindent = true;
    smartindent = true;
    guicursor = "n-v-c:block,i:ver25";

    # any other vim.opt you like
  };
}
