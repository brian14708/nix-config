{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    ./disko.nix
    ../aether/mihomo.nix
    ../base
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "mitigations=off" ];
    initrd.systemd.enable = true;
    loader = {
      systemd-boot = {
        enable = false;
        configurationLimit = 5;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  sops = {
    defaultSopsFile = ./secret.yaml;
    age.sshKeyPaths = [ "/etc/sops-nix/id_ed25519" ];
    gnupg.sshKeyPaths = [ ];
    secrets."brian-password" = {
      neededForUsers = true;
    };
    secrets."mihomo-url" = { };
  };

  networking = {
    hostName = "fuxi";
    networkmanager.enable = true;
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      hashedPassword = "!";
    };
    brian = {
      uid = 1000;
      description = "Brian";
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = (import ../../home/brian/_user.nix).ssh;
      hashedPasswordFile = config.sops.secrets."brian-password".path;
    };
  };

  hardware.enableRedistributableFirmware = true;
  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
    };
  };

  system.stateVersion = "24.11";

  programs.hyprland.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time";
        user = "greeter";
      };
    };
  };

  hardware.graphics = {
    enable = true;
  };
}
