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
      nixfmt-rfc-style
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
  };
  xdg.configFile."ghostty/config".text = ''
    font-family = "Maple Mono NF CN"
    theme = "catppuccin-mocha"
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
}
