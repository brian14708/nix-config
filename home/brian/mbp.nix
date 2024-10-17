{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./common ];
  home.username = "brian";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    colima
    docker-client
  ];
}
