{ config, pkgs, ... }:
{
  home.username = "brian";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

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

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "Brian Li";
      userEmail = "me@brian14708.dev";
      difftastic.enable = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      use-xdg-base-directories = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://mirrors.cernet.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };

}
