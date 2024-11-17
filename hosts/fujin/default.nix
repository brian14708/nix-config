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
    secrets."brian/password" = {
      neededForUsers = true;
    };
    secrets."brian/sops" = {
      owner = "brian";
      path = "/home/brian/.config/sops/age/keys.txt";
    };
  };

  networking = {
    hostName = "fujin";
    networkmanager.enable = true;
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      hashedPassword = "!";
    };
    brian =
      let
        u = config.userinfos.brian;
      in
      {
        uid = 1000;
        description = u.name;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = u.ssh;
        hashedPasswordFile = config.sops.secrets."brian/password".path;
      };
    ops = {
      uid = 2000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = config.userinfos.brian.ssh;
      hashedPassword = "!";
    };
  };
  security.sudo.extraRules = [
    {
      users = [ "ops" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  services.hardware.bolt.enable = true;
  hardware.nvidia.open = true;
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];

  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
    };
  };

  system.stateVersion = "24.11";
}
