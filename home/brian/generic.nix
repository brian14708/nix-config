{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./common
    ../../modules/home/development/vim
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
