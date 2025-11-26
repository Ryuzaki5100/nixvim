{ ... }:
{
  plugins.treesitter = {
    enable = true;
    folding = true;
    settings.autoindent = true;
    settings.copyindent = true;
    settings.preserveindent = true;
    nixvimInjections = true;

    settings.ensure_installed = [
      "java"
      "kotlin"
      "bash"
      "nix"
      "lua"
      "markdown"
      "markdown_inline"
      "json"
      "yaml"
      "toml"
      "dockerfile"
      "git_rebase"
      "gitcommit"
      "gitignore"
    ];
  };

  plugins.treesitter-context.enable = true;
  plugins.treesitter-refactor.settings = {
    enable = true;
    highlightDefinitions.enable = true;
    smartRename.enable = true;
  };
}
