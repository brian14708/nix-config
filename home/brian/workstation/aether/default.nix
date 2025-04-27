{
  pkgs,
  ...
}:
{
  imports = [
    ../base-linux.nix
    ../../features/desktop/hyprland
    ../../features/desktop/fcitx5
    ../../features/desktop/media
    ../../features/desktop/chromium
    ../../features/development/vscode
    ../../features/development/emacs
    ../../features/development/cli
    ../../features/themes/catppuccin
  ];

  home = {
    username = "brian";
    stateVersion = "24.11";
  };
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
  };
  sops = {
    defaultSopsFile = ./secrets.yaml;
  };
}
