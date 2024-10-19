{
  config,
  pkgs,
  lib,
  inputs,
  machine,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./git.nix
  ];

  news.display = false;
  home.preferXdgDirectories = true;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

  programs = {
    home-manager.enable = true;
  };

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };

  sops.secrets = lib.optionalAttrs machine.trusted {
    "nix.conf" = {
      sopsFile = ./nix.secret.yaml;
    };
  };

  nix =
    {
      package = lib.mkDefault pkgs.nixVersions.latest;
      settings = {
        use-xdg-base-directories = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://mirrors.cernet.edu.cn/nix-channels/store"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    }
    // lib.optionalAttrs machine.trusted {
      extraOptions = "include ${config.sops.secrets."nix.conf".path}\n";
      checkConfig = false;
    };
}
