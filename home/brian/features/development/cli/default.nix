{ lib, ... }:
{
  programs = {
    yazi.enable = true;
    eza.enable = true;
    jq.enable = true;
    bash.enable = true;
    starship.enable = true;
    zoxide.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
  programs.bash = {
    bashrcExtra = lib.mkAfter ''
      if command -v direnv >/dev/null 2>&1; then
        if [ -n "$CLAUDECODE" ]; then
          eval "$(direnv hook bash)"
          eval "$(DIRENV_LOG_FORMAT= direnv export bash)"
        fi
      fi
    '';
  };
}
