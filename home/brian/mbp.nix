{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./common ];
  home = {
    username = "brian";
    stateVersion = "24.05";
    packages = with pkgs; [
      colima
      docker-client
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];
  };
}
