{ ... }: {
  plugins = {
    dap.enable = true;
    dap-ui.enable = true;
    dap-virtual-text.enable = true;
  };

  keymaps = [
    { key = "<F5>";  action = "<cmd>lua require'dap'.continue()<CR>"; }
    { key = "<F10>"; action = "<cmd>lua require'dap'.step_over()<CR>"; }
    { key = "<F11>"; action = "<cmd>lua require'dap'.step_into()<CR>"; }
    { key = "<F12>"; action = "<cmd>lua require'dap'.step_out()<CR>"; }
    { key = "<F9>";  action = "<cmd>lua require'dap'.toggle_breakpoint()<CR>"; }
    { key = "<leader>db"; action = "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>"; }
    { key = "<leader>dr"; action = "<cmd>lua require'dap'.repl.open()<CR>"; }
    { key = "<leader>dl"; action = "<cmd>lua require'dap'.run_last()<CR>"; }
    { key = "<leader>du"; action = "<cmd>lua require'dapui'.toggle()<CR>"; }
  ];
}
