{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.username = "brian";
  home.stateVersion = "24.05";

  home.packages =
    with pkgs;
    [
      devenv
    ]
    ++ lib.optionals stdenv.isDarwin [
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
