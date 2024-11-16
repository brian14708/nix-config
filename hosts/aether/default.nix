{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ../profiles/linux
    ../features/network/mihomo.nix
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
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."brian-password" = {
      neededForUsers = true;
    };
  };

  networking = {
    hostName = "aether";
    networkmanager.enable = true;
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      hashedPassword = "!";
    };
    brian =
      let
        id = config.identity.brian;
      in
      {
        uid = 1000;
        description = id.name;
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ];
        openssh.authorizedKeys.keys = id.ssh;
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
