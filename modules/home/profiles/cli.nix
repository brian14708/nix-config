{
  flake.modules.homeManager.cli =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      hasAi = config ? sops && config.sops.secrets ? "configs/ai";
      aiEnv = config.sops.secrets."configs/ai".path;
      codexTemplate = (pkgs.formats.toml { }).generate "codex-config.toml" {
        model_provider = "proxy";
        model_providers.proxy = {
          name = "proxy";
          base_url = "__OPENAI_BASE_URL__";
          env_key = "OPENAI_API_KEY";
          wire_api = "responses";
          requires_openai_auth = true;
        };
        analytics.enabled = false;
      };
    in
    {
      xdg.configFile."mise/config.toml".source = (pkgs.formats.toml { }).generate "mise.toml" {
        settings = {
          minimum_release_age = "0";
          # Keep mise's NixOS node source-build behavior explicit while
          # retaining precompiled runtimes on Darwin.
          all_compile = pkgs.stdenv.hostPlatform.isLinux;
        };
        tools = {
          codex = "latest";
          "claude-code" = "latest";
        };
      };

      # Optional: provide AI CLI wrappers when the secret is present.
      home.packages =
        let
          agentLauncher = pkgs.writeShellApplication {
            name = "agent";
            runtimeInputs = with pkgs; [
              coreutils
              fzf
              gnugrep
            ];
            text = ''
              set -Eeuo pipefail
              IFS=$'\n\t'
              state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/desktop-agent/default"
              configured="codex"
              permission="auto"

              selected() {
                if [ -s "$state_file" ]; then
                  head -n 1 "$state_file"
                else
                  printf '%s\n' "$configured"
                fi
              }

              usage() {
                echo "Usage: agent [pick|prompt <text...>|doctor]"
              }

              pick() {
                mkdir -p "$(dirname "$state_file")"
                choice=$(printf 'claude\ncodex\n' | fzf --prompt='Agent> ' --height=40% --layout=reverse --border) || exit 0
                case "$choice" in
                  claude|codex) printf '%s\n' "$choice" > "$state_file"; echo "Default agent: $choice" ;;
                  *) echo "Unsupported agent: $choice" >&2; exit 1 ;;
                esac
              }

              agent=$(selected)
              case "''${1:-}" in
                pick) pick; exit 0 ;;
                doctor)
                  printf 'agent=%s\npermission=%s\n' "$agent" "$permission"
                  command -v "$agent" >/dev/null 2>&1 || { echo "missing executable: $agent" >&2; exit 1; }
                  echo ready
                  exit 0
                  ;;
                prompt) shift; [ "$#" -gt 0 ] || { usage >&2; exit 2; }; prompt="$*" ;;
                -h|--help) usage; exit 0 ;;
                "") prompt="" ;;
                *) prompt="$*" ;;
              esac

              command -v "$agent" >/dev/null 2>&1 || {
                echo "$agent is not installed; run: agent pick" >&2
                exit 1
              }

              case "$agent:$permission" in
                claude:ask) set -- claude ;;
                claude:auto) set -- claude --permission-mode acceptEdits ;;
                claude:unrestricted) set -- claude --dangerously-skip-permissions ;;
                codex:ask) set -- codex ;;
                codex:auto) set -- codex --approve-for-me ;;
                codex:unrestricted) set -- codex --dangerously-bypass-approvals-and-sandbox ;;
                *) echo "unsupported agent policy: $agent:$permission" >&2; exit 1 ;;
              esac
              [ -n "$prompt" ] && set -- "$@" "$prompt"
              exec "$@"
            '';
          };
        in
        (with pkgs; [
          agentLauncher
          mise
          fastmod
          devenv
        ])
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.bubblewrap
        ]
        ++ lib.optionals hasAi [
          (pkgs.writeShellApplication {
            name = "claude";
            text = ''
              set -Eeuo pipefail
              # shellcheck disable=SC1091
              source ${aiEnv}
              if [ -n "''${ANTHROPIC_MODEL:-}" ]; then
                export ANTHROPIC_DEFAULT_FABLE_MODEL="$ANTHROPIC_MODEL"
                export ANTHROPIC_DEFAULT_OPUS_MODEL="$ANTHROPIC_MODEL"
                export ANTHROPIC_DEFAULT_SONNET_MODEL="$ANTHROPIC_MODEL"
                export ANTHROPIC_DEFAULT_HAIKU_MODEL="$ANTHROPIC_MODEL"
                export CLAUDE_CODE_SUBAGENT_MODEL="$ANTHROPIC_MODEL"
              fi
              exec ${lib.getExe pkgs.mise} exec --quiet claude-code -- claude "$@"
            '';
            checkPhase = "";
            runtimeInputs = [ pkgs.mise ];
            runtimeEnv = {
              CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
              CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
              CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
              CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
              DISABLE_TELEMETRY = "1";
            };
          })
          (pkgs.writeShellApplication {
            name = "codex";
            text = ''
              set -Eeuo pipefail
              # shellcheck disable=SC1091
              source ${aiEnv}
              mkdir -p "$CODEX_HOME"
              config_file="$CODEX_HOME/config.toml"
              if [ ! -e "$config_file" ]; then
                install -m 600 ${codexTemplate} "$config_file"
              fi
              [ -f "$config_file" ] || {
                echo "Codex config is not a regular file: $config_file" >&2
                exit 1
              }
              [ -n "''${OPENAI_BASE_URL:-}" ] || {
                echo "OPENAI_BASE_URL is required by the Codex wrapper" >&2
                exit 1
              }
              escaped_base_url=$(printf '%s' "$OPENAI_BASE_URL" | sed 's/[&|\\]/\\&/g')
              sed -i \
                -e "s|^openai_base_url = \".*\"$|openai_base_url = \"$escaped_base_url\"|" \
                -e "s|^base_url = \".*\"$|base_url = \"$escaped_base_url\"|" \
                "$config_file"
              exec ${lib.getExe pkgs.mise} exec --quiet codex -- codex "$@"
            '';
            checkPhase = "";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.gnused
              pkgs.mise
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
