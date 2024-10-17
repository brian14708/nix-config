{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./common ];
  home.username = "brian";
  home.stateVersion = "24.11";

  home.packages =
    with pkgs;
    [
    ];
}
