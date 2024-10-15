{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./global ];
  home.username = "brian";
  home.stateVersion = "24.05";

  home.packages =
    with pkgs;
    [
    ];
}
