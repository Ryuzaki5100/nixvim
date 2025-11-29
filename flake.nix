{
  description = "My perfect portable Neovim IDE – brings its own clang, java, rust-analyzer, etc.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils"; # optional, but keeps it if you added it
  };

  outputs =
    {
      nixvim,
      flake-parts,
      flake-utils,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { system, pkgs, ... }:
        let
          nixvimLib = nixvim.lib.${system};
          nixvim' = nixvim.legacyPackages.${system};

          # All the tools you want available inside Neovim (LSPs, compilers, debuggers…)
          lspTools = with pkgs; [
            # C / C++
            llvmPackages_18.clang-tools
            clang
            gnumake
            cmake
            gdb
            lldb

            # Java
            jdk21
            jdt-language-server

            # Rust
            rust-analyzer
            rustc
            cargo

            # Python
            pyright
            ruff
            black
            python3

            # Go
            gopls
            go

            # Node / JS/TS
            nodePackages.typescript-language-server
            nodePackages.vscode-langservers-extracted
            nodejs

            ripgrep

            # Lua, Nix, Markdown, etc.
            lua-language-server
            stylua
            nil
            nixfmt-rfc-style
            marksman
            taplo
            yaml-language-server
          ];

          nixvimModule = {
            inherit pkgs; # ← give your config direct access to pkgs
            module = {
              _module.args.lspTools = lspTools; # ← pass the tools to your config module
              imports = [ ./config ]; # ← import as a list (enables composition)
            };
            extraSpecialArgs = { inherit lspTools; }; # ← optional: also pass directly if needed
          };

          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in
        {
          checks.default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;

          packages = {
            default = nvim; # nix run . → opens your IDE
            nvim = nvim; # also available as nix run .#nvim
          };

          # Optional: `nix develop` drops you in a shell with everything + handy aliases
          devShells.default = pkgs.mkShell {
            buildInputs = [ nvim ] ++ lspTools;
            shellHook = ''
              echo "Greetings Boss"
              alias vim=nvim
              alias vi=nvim
            '';
          };
        };
    };
}
