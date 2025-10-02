{
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      jjui
    ];
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      ui.default-command = "log";
      fix.tools = {
        nixfmt = {
          command = [
            "nix"
            "run"
            "nixpkgs#nixfmt"
            "--"
            "--filename=$path"
          ];
          patterns = [ "glob:'**/*.nix'" ];
        };
        ruff = {
          command = [
            "nix"
            "run"
            "nixpkgs#ruff"
            "--"
            "format"
            "--stdin-filename=$path"
          ];
          patterns = [ "glob:'**/*.py'" ];
        };
      };
    };
  };
  programs.difftastic = {
    enable = true;
    options.display = "inline";
    git.enable = true;
  };
  programs.git = {
    enable = true;
    settings = {
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
      pull.rebase = true;
      init.defaultBranch = "main";
    };
    lfs.enable = true;
    ignores = [
      ".DS_Store"
      "/.direnv"
      "/.envrc"
      "/.env"
      ".clangd/"
      ".claude"
      "/.todo"
      "CLAUDE.md"
      "AGENTS.md"
    ];
  };
}
