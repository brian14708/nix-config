let
  agentDirenvExport = ''
    if command -v direnv >/dev/null 2>&1 && [ -n "''${CLAUDECODE:-}" ]; then
      eval "$(DIRENV_LOG_FORMAT= direnv export bash)"
    fi
  '';
in
{
  flake.modules.homeManager.shell =
    { lib, ... }:
    {
      programs = {
        starship.enable = true;
        zoxide.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        carapace.enable = true;
        bash = {
          enable = true;
          bashrcExtra = lib.mkAfter agentDirenvExport;
        };
      };
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      tools = with pkgs; [
        self'.packages.nvim
        self'.packages.qalc
        bashInteractive
        carapace
        coreutils
        curl
        delta
        devenv
        difftastic
        direnv
        eza
        fastmod
        fd
        file
        findutils
        fzf
        git
        git-lfs
        gnugrep
        gnused
        gnutar
        gzip
        jjui
        jq
        jujutsu
        less
        mise
        nix
        openssh
        ripgrep
        starship
        unzip
        wget
        yazi
        zoxide
      ];
      direnvConfig = pkgs.writeTextDir "direnvrc" ''
        source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
      '';
      bashrc = pkgs.writeText "shell.bashrc" ''
        HISTFILE="''${XDG_STATE_HOME:-$HOME/.local/state}/nix-shell/history"
        mkdir -p -- "''${HISTFILE%/*}"
        HISTCONTROL=ignoreboth
        HISTSIZE=10000
        HISTFILESIZE=100000
        shopt -s histappend checkwinsize
        PROMPT_COMMAND='history -a; history -n'

        source ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh
        alias ls='eza'
        alias ll='eza -l'
        alias la='eza -a'
        alias lla='eza -la'
        alias lt='eza --tree'

        y() {
          local tmp cwd
          tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return
          ${lib.getExe pkgs.yazi} "$@" --cwd-file="$tmp"
          if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }

        eval "$(${lib.getExe pkgs.carapace} _carapace bash)"
        eval "$(${lib.getExe pkgs.zoxide} init bash)"
        eval "$(${lib.getExe pkgs.starship} init bash)"
        eval "$(${lib.getExe pkgs.direnv} hook bash)"
        ${agentDirenvExport}
      '';
    in
    {
      packages.shell = pkgs.writeShellApplication {
        name = "shell";
        runtimeInputs = tools;
        runtimeEnv = {
          EDITOR = lib.getExe self'.packages.nvim;
          VISUAL = lib.getExe self'.packages.nvim;
          PAGER = "${lib.getExe pkgs.less} -RXF";
        };
        text = ''
          export DIRENV_CONFIG="''${DIRENV_CONFIG:-${direnvConfig}}"
          export SHELL="$0"
          exec ${lib.getExe pkgs.bashInteractive} --noprofile --rcfile ${bashrc} "$@"
        '';
        meta.description = "Configured Bash environment with development tools";
      };
    };
}
