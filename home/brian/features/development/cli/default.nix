{
  pkgs,
  lib,
  config,
  ...
}:
{
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
  home.packages = [
    (pkgs.writeScriptBin "claude" ''
      #! /usr/bin/env nix-shell
      #! nix-shell -i bash -p bash nodejs pnpm
      source ${config.sops.secrets.claude.path}
      pnpm dlx "@anthropic-ai/claude-code" "$@"
    '')
  ];

}
