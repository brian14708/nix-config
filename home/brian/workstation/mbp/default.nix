{
  pkgs,
  ...
}:
{
  imports = [
    ../../profiles/base
    ../../features/development/cli
  ];
  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      colima
      docker-client
      nil
      nixfmt
      maple-mono.NF-CN
    ];
  };
  programs.zsh.enable = true;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    environment.SOPS_GPG_EXEC = "/dev/null";
    age.sshKeyPaths = [ ];
    age.keyFile = "/Users/brian/.config/sops/age/keys.txt";
    gnupg.sshKeyPaths = [ ];
    secrets."ssh" = {
      path = "/Users/brian/.ssh/id_ed25519";
    };
    secrets."ai" = {
      sopsFile = ../secrets.yaml;
    };
  };
  xdg.configFile."ghostty/config".text = ''
    font-family = "Maple Mono NF CN"
    theme = "Catppuccin Mocha"
  '';
  programs.neovide = {
    settings = {
      fork = true;
      font = {
        normal = [ "Maple Mono NF CN" ];
        size = 12;
      };
      theme = "dark";
      frame = "transparent";
    };
  };
  targets.darwin.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  programs.jujutsu = {
    settings = {
      ui.pager = ":builtin";
    };
  };
  programs.ssh = {
    matchBlocks."github.com" = {
      hostname = "github.com";
      proxyCommand = "${pkgs.corkscrew}/bin/corkscrew 127.0.0.1 6152 %h %p";
    };
  };
}
