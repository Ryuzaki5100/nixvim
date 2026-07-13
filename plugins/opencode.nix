{
  config,
  pkgs,
  ...
}:
{
  plugins.opencode = {
    enable = true;
    autoLoad = true;

    settings = {
      auto_reload = false;
      port = 8080;
      events = {
        enabled = true;
        reload = true;
        permissions = {
          enabled = true;
          edits.enabled = true;
        };
      };
      prompts = {
        ask = "...";
        diagnostics = "Explain @diagnostics";
        document = "Add comments documenting @this";
        explain = "Explain @this and its context";
        fix = "Fix @diagnostics";
        implement = "Implement @this";
        optimize = "Optimize @this for performance and readability";
        review = "Review @this for correctness and readability";
        test = "Add tests for @this";
      };
    };
  };

  keymaps = [
    {
      mode = [ "n" "x" ];
      key = "<leader>oa";
      action = ''<cmd>lua require("opencode").ask("@this: ")<CR>'';
      options.desc = "Ask OpenCode...";
    }
    {
      mode = [ "n" "x" ];
      key = "<leader>os";
      action = ''<cmd>lua require("opencode").select()<CR>'';
      options.desc = "Select OpenCode prompt...";
    }
    {
      mode = [ "n" "x" ];
      key = "go";
      action.__raw = ''
        function() return require("opencode").operator("@this ") end
      '';
      options.desc = "Append range to OpenCode";
    }
    {
      mode = "n";
      key = "goo";
      action.__raw = ''
        function() return require("opencode").operator("@this ") .. "_" end
      '';
      options.desc = "Append line to OpenCode";
    }
    {
      mode = "n";
      key = "<S-C-u>";
      action = ''<cmd>lua require("opencode").command("session.half.page.up")<CR>'';
      options.desc = "Scroll OpenCode up";
    }
    {
      mode = "n";
      key = "<S-C-d>";
      action = ''<cmd>lua require("opencode").command("session.half.page.down")<CR>'';
      options.desc = "Scroll OpenCode down";
    }
  ];
}
