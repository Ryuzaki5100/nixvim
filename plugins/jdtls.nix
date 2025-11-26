# nixvim-config/plugins/jdtls.nix
{ pkgs, ... }:
{
  plugins = {
    # This gives you :JdtRefresh, :JdtCompile, etc.
    jdtls.enable = true;

    lsp.servers.jdtls = {
      enable = true;

      rootMarkers = [
        "pom.xml"
        "build.gradle"
        "build.gradle.kts"
      ];

      extraOptions.root_dir = /* lua */ ''
        function(fname)
          local current = vim.fn.fnamemodify(fname, ':p:h')
          while current and current ~= '/' do
            local self_pom    = current .. '/pom.xml'
            local service_dir = current .. '/service'
            local service_pom = service_dir .. '/pom.xml'
            if vim.loop.fs_stat(self_pom) and vim.loop.fs_stat(service_pom) then
              return service_dir
            end
            local parent = vim.fn.fnamemodify(current, ':h')
            if parent == current then break end
            current = parent
          end
          return require('lspconfig.util').root_pattern('pom.xml')(fname)
        end
      '';

      settings.java.configuration.runtimes = [
        {
          name = "JavaSE-1.8";
          path = "${pkgs.jdk8}/lib/openjdk";
        }
        {
          name = "JavaSE-17";
          path = "${pkgs.openjdk17}/lib/openjdk";
        }
        {
          name = "JavaSE-21";
          path = "${pkgs.openjdk21}/lib/openjdk";
        }
      ];

      settings.java = {
        project.importOnFirstRun = false;
        maxConcurrentBuilds = 1;
        autobuild.enabled = true;
        saveActions.organizeImports = true;
        jdt.ls.vmargs = "-Xmx2G -XX:+UseParallelGC";
      };
    };

    # Make sure which-key shows descriptions
    which-key.enable = true;
  };

  # Keymaps using options.desc (exactly as you want)
  keymaps = [
    {
      key = "<leader>lj";
      action = "<cmd>LspRestart<CR>";
      options = {
        desc = "Restart jdtls";
        silent = true;
      };
    }
    {
      key = "<leader>lJ";
      action = "<cmd>JdtRefresh<CR>"; # ← NOW WORKS
      options = {
        desc = "Refresh current project";
        silent = true;
      };
    }
    {
      key = "<leader>lk";
      action = /* lua */ ''
        <cmd>lua
          local clients = vim.lsp.get_clients({ name = "jdtls" })
          if #clients == 0 then
            print("No jdtls client running")
            return
          end
          local client = clients[1]
          local root = client.config.root_dir or "unknown"
          local runtimes = client.config.settings.java.configuration.runtimes or {}
          print("jdtls root: " .. root)
          for _, rt in ipairs(runtimes) do
            local def = rt.default and " (default)" or ""
            print(" • " .. rt.name .. def)
          end
          vim.lsp.buf_notify(0, "java/getActiveJavaRuntime", {}, function(_, r)
            if r and r.name then print("Active JDK: " .. r.name) end
          end)
        <CR>
      '';
      options = {
        desc = "Show jdtls root + JDKs";
        silent = true;
      };
    }
  ];
}
