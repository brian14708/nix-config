{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.git = {
    enable = true;
    userName = "Brian Li";
    userEmail = "me@brian14708.dev";
    difftastic.enable = true;
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519.pub";
    };
    aliases = {
      sclone = "clone --filter=blob:none";
      pushf = "push --force-with-lease";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      fixup = "!git commit --fixup $(git select)";
      select = "!git log --oneline --decorate --color | ${pkgs.fzf}/bin/fzf +s +m --ansi | ${pkgs.gnused}/bin/sed \"s/ .*//\"";
      gc-all = "!git reflog expire --expire=now --all && git gc --aggressive --prune=now";
      cleanup = "!git branch --merged | grep -E -v '^\\*|master|dev' | xargs -r git branch -d";
      uncommit = "reset HEAD~1";
      save = "commit -am";
      graph = "log --pretty=oneline --graph --decorate --all";
      large-blobs = ''
        !git rev-list --objects --all | \
            git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
            ${pkgs.gnused}/bin/sed -n 's/^blob //p' |
            sort --numeric-sort --key=2 |
            cut -c 1-12,41- |
            numfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
      '';
    };
    extraConfig = {
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
    };
    lfs.enable = true;
    ignores = [
      "/.direnv"
      "/.envrc"
      "/.env"
      ".clangd/"
      ".aider.*"
    ];
  };
  home.file.".config/git/allowed_signers" = {
    text = ''
      # personal machines
      me+tyr@brian14708.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcqBFMZB3bOLhrGpQ7TmGORGuHrrbLrK7jqv50wrtTM
      me+aether@brian14708.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwbb5dzEGxfe1A5l6pQyo4aUc1cIyl1k6ns7ZJDnDKj
      me+styx@brian14708.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFG/Ck0eF0bjuW2aK3hOk4Iy3aM1KpTbhZiN+wPpi4tm
      me+mbp@brian14708.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtwJfAEa7AUAS4gaJfiU0bTH1QNHJwTRFlI6NuNqFaD
      # certificate authority
      me@brian14708.dev cert-authority ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeS6dWCB0TwwnmL6ynrQuLr5jsqS0dwjuwgw3FLen9P1hg+PMhwyw2G7ABfogZHwNG5y2jvB5iLfclrKPDQ/B31oJeWMV5hilDIiTLPTtIqKd93QQujyyLUqznC3dYNzJC7vBr0HGcR6te90Fjk80vsfFUQ/kE3PVJVGguhZI9TX9T2JepOlyQ597NSNuNkx7GUG9vrdZwxkyC3PUu2ipyLOvmLTiRPgl0wLXoIHUTgt0GfM5KpF3tlSirrWBu9WFdfL37YDvQt7JhqmsIXuUusNRw95HlROTujjV5xgWmv59t7TIdWRO3M2wzNQ257Wd3TZXmoYyk5TSzLvIWXb9dW0KlK4u8xaK0CU/H4Ro30coWveujmCX3jAxfAFpCSDHsy79JX/MIi43HnLJjvBY+1/VCwKwGUyXajq8/5XOCdBYYcQcNzfvWPoA2j8VlkxgaMHQ7i5tUy2dAHzKdJDmfuSyDrHEzfgGpAna8NaRbH5WKMpxX7dmlgmI0kWOw1nojfC8CCJyfEYPS81b7m9Z65C0+m+zhruUY9A/v3MdmwHlnkMMFmLHaavJSxK1U1ROGs/MYEiauBZiYiFPXbJnDNrU7hujTwdXvO5adJO8oZ9byOazB09vnRNQgc/X6hIas2Fh13tQ8NMbqZGWLcmfH6LkdjrVloRbbV7QtU0GCGQ==
    '';
  };
}
