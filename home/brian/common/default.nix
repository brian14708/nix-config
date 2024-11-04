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
    ../../../modules/home/development/vim
    ./git.nix
  ];

  news.display = "silent";
  home.preferXdgDirectories = true;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

  programs = {
    home-manager.enable = true;
  };

  sops = {
    gnupg.home = "${config.xdg.configHome}/sops-nix/gnupg";
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
        use-xdg-base-directories = !config.targets.genericLinux.enable;
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
    }
    // lib.optionalAttrs machine.trusted {
      extraOptions = "include ${config.sops.secrets."nix.conf".path}\n";
      checkConfig = false;
    };
}
