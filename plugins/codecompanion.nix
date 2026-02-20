# nixvim/plugins/codecompanion.nix
{ config, pkgs, ... }:

{
  plugins.codecompanion = {
    enable = true;

    settings = {
      strategies = {
        chat.adapter = "mistral";
        inline.adapter = "mistral"; # enables Copilot-like inline completions
      };

      adapters = {
        gemini = {
          env = {
            # Secure: reads from your Fish env var (set via set -Ux GEMINI_API_KEY "...")
            api_key = "cmd:echo $GEMINI_API_KEY";
          };

          # Choose model (update as Google adds newer ones)
          schema.model.default = "gemini-2.5-flash"; # fast & good for code
          # Alternatives: "gemini-2.5-flash" or "gemini-2.5-pro"

          # Optional: model capabilities
          schema.model.choices = {
            "gemini-2.5-flash" = {
              opts = {
                can_reason = true;
                has_vision = true;
              };
            };
          };
        };
        mistral = {
          env = {
            api_key = "cmd:echo $MISTRAL_API_KEY";
          };
          schema.model.default = "mistral-7b-instruct-v0.1.Q4_0.gguf";
          schema.model.choices = {
            "mistral-7b-instruct-v0.1.Q4_0.gguf" = {
              opts = {
                can_reason = true;
                has_vision = true;
              };
            };
          };
        };

        # UI/UX tweaks
        display = {
          action_palette.provider = "telescope"; # or "mini"
          chat.window.width = 0.4;
        };

        opts.completion = true; # integrates with nvim-cmp for popup fallback
      };
    };
  };

  # Often paired with this for better completion experience
  plugins.cmp.enable = true;
}
