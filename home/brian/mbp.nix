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

  home.packages = with pkgs; [
    colima
    docker-client
  ];

  programs.git = {
    enable = true;
    userName = "Brian Li";
    userEmail = "me@brian14708.dev";
    difftastic.enable = true;
  };
}
