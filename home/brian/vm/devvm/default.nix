{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../../profiles/base
    ../../features/desktop/niri
    ../../features/desktop/fcitx5
    ../../features/desktop/media
    ../../features/desktop/chromium
    ../../features/development/cli
    ../../features/themes/catppuccin
  ];

  home = {
    username = "brian";
    stateVersion = "25.05";
  };
  my.desktop.enable = true;
  #sops = {
  #  defaultSopsFile = ./secrets.yaml;
  #};
}
