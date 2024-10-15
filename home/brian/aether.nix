{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./global ];
  home.username = "brian";
  home.stateVersion = "24.11";

  home.packages =
    with pkgs;
    [
    ];
}
