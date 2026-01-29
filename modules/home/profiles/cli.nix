{
  flake.modules.homeManager.cli =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      # Optional: provide AI CLI wrappers when the secret is present.
      home.packages =
        let
          hasAi = config ? sops && config.sops.secrets ? "configs/ai";
          aiEnv = config.sops.secrets."configs/ai".path;
        in
        (with pkgs; [ fastmod ])
        ++ lib.optionals hasAi [
          (pkgs.writeShellApplication {
            name = "claude";
            text = ''
              source ${aiEnv}
              exec pnpm dlx "@anthropic-ai/claude-code" "$@"
            '';
            checkPhase = "";
            runtimeInputs = [
              pkgs.nodejs
              pkgs.pnpm
            ];
            runtimeEnv = {
              CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
            };
          })
          (pkgs.writeShellApplication {
            name = "codex";
            text = ''
              source ${aiEnv}
              exec pnpm dlx "@openai/codex" "$@"
            '';
            checkPhase = "";
            runtimeInputs = [
              pkgs.nodejs
              pkgs.pnpm
            ];
            runtimeEnv = {
              CODEX_HOME = "${config.xdg.configHome}/codex";
            };
          })
        ];

      programs = {
        yazi.enable = true;
        eza.enable = true;
        ripgrep.enable = true;
        jq.enable = true;
        bash.enable = true;
        starship.enable = true;
        zoxide.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        nushell = {
          enable = true;
          extraConfig = ''
            $env.config.show_banner = false
          '';
        };
        carapace = {
          enable = true;
          enableNushellIntegration = true;
        };
        bash = {
          bashrcExtra = lib.mkAfter ''
            if command -v direnv >/dev/null 2>&1; then
              if [ -n "$CLAUDECODE" ]; then
                eval "$(direnv hook bash)"
                eval "$(DIRENV_LOG_FORMAT= direnv export bash)"
              fi
            fi
          '';
        };
      };
    };
}
