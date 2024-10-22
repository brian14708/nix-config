{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./common
    ../../modules/home/editors/vim
  ];
  targets.genericLinux.enable = true;
  programs.fish.enable = true;
  home = {
    username = "brian";
    stateVersion = "24.05";
    packages =
      [
      ];
  };
}
