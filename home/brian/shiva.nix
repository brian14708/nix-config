{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./common
    ../../modules/home/development/emacs
  ];
  home = {
    username = "brian";
    stateVersion = "24.05";
    packages =
      [
      ];
  };
}
