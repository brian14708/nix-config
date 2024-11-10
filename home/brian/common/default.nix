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
    ../../../modules/home/development/git
  ];

  news.display = "silent";
  home.preferXdgDirectories = true;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.git = {
    userName = "Brian Li";
    userEmail = "me@brian14708.dev";
    signing = {
      key = "91C32271A5A151D38526881FD03DD6ED48DEE9CE";
    };
  };

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
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://brian14708.cachix.org"
          "https://cache.nixos.org"
        ];
        extra-trusted-public-keys = [
          "brian14708.cachix.org-1:ZTO1dfqDryBeRpLJwn/czQj0HFC0TPuV2aK+81o2mSs="
        ];
      };
    }
    // lib.optionalAttrs machine.trusted {
      extraOptions = "!include ${config.sops.secrets."nix.conf".path}\n";
      checkConfig = false;
    };
}
