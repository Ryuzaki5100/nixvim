{ pkgs, ... }:

# clangd uses its own clang frontend, so it does not know about GNU GCC's
# libstdc++ headers (e.g. <bits/stdc++.h>, which has no libc++ equivalent).
# Pointing clangd at our GCC driver via `CompileFlags.Compiler` -- together with
# `--query-driver` in plugins/lsp.nix -- makes it query that driver for the
# system include paths, so the editor resolves the same standard library the
# compiler uses.
#
# The config must exist before clangd starts and before anything else runs, so
# it is written from `extraConfigLuaPre`. Doing it here (rather than in a
# devShell shellHook) means it works for every launch method (`nix run`,
# `nix develop`, GUI launchers) on both macOS and Linux.
let
  gpp = "${pkgs.gcc}/bin/g++";
in
{
  extraConfigLuaPre = ''
    do
      local dir
      local xdg = vim.env.XDG_CONFIG_HOME
      if xdg and xdg ~= "" then
        dir = xdg .. "/clangd"
      elseif vim.uv.os_uname().sysname == "Darwin" then
        dir = (vim.env.HOME or "") .. "/Library/Preferences/clangd"
      else
        dir = (vim.env.HOME or "") .. "/.config/clangd"
      end
      local path = dir .. "/config.yaml"
      if vim.fn.filereadable(path) == 0 then
        vim.fn.mkdir(dir, "p")
        vim.fn.writefile({ "CompileFlags:", "  Compiler: ${gpp}" }, path)
      end
    end
  '';
}
