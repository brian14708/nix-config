{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./git.nix
  ];

  home.preferXdgDirectories = true;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

  programs = {
    home-manager.enable = true;
  };

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };

  sops.secrets = {
    "nix.conf" = {
      sopsFile = ../secrets/global.nix.yaml;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nixVersions.latest;
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
    extraOptions = "include ${config.sops.secrets."nix.conf".path}\n";
    checkConfig = false;
  };
}
