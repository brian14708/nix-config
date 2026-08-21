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
        (with pkgs; [
          fastmod
          devenv
          (writeShellApplication {
            name = "ob";
            text = ''
              exec pnpm --allow-build=better-sqlite3 dlx obsidian-headless "$@"
            '';
            checkPhase = "";
            runtimeInputs = [
              nodejs
              pnpm
            ];
          })
        ])
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.bubblewrap
        ]
        ++ lib.optionals hasAi [
          (pkgs.writeShellApplication {
            name = "claude";
            text = ''
              source ${aiEnv}
              export PNPM_CONFIG_MINIMUM_RELEASE_AGE=0
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
              ${pkgs.gnused}/bin/sed -i 's|base_url = ".*"|base_url = "'"$OPENAI_BASE_URL"'"|g' "$CODEX_HOME/config.toml"
              export PNPM_CONFIG_MINIMUM_RELEASE_AGE=0
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
        yazi = {
          enable = true;
          shellWrapperName = "y";
        };
        eza.enable = true;
        ripgrep.enable = true;
        herdr = {
          enable = true;
          settings = {
            terminal.shell_mode = "login";
            update.version_check = false;
            ui = {
              agent_panel_sort = "priority";
              status_indicators = "symbols";
              hide_tab_bar_when_single_tab = true;
              show_agent_labels_on_pane_borders = true;
              sound.enabled = false;
              toast.delivery = "terminal";
            };
            onboarding = false;
          };
        };
        zellij = {
          enable = false;
          settings = {
            pane_frames = false;
            show_startup_tips = false;
            default_layout = "compact";
            env = {
              TERM = "xterm-256color";
              COLORTERM = "truecolor";
            };
          };
        };
        jq.enable = true;
        starship.enable = true;
        zoxide.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        carapace.enable = true;
        bash = {
          enable = true;
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
