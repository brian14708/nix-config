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
    hostName = "fujin";
    networkmanager.enable = true;
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      hashedPassword = "!";
    };
    brian = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = (import ../../home/brian/_user.nix).ssh;
      hashedPasswordFile = config.sops.secrets."brian-password".path;
    };
    ops = {
      uid = 2000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = (import ../../home/brian/_user.nix).ssh;
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

  nix = {
    settings = {
      use-xdg-base-directories = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://brian14708.cachix.org"
        "https://cache.nixos.org"
      ];
      extra-trusted-public-keys = [
        "brian14708.cachix.org-1:ZTO1dfqDryBeRpLJwn/czQj0HFC0TPuV2aK+81o2mSs="
      ];
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  services.dbus.implementation = "broker";
  services.speechd.enable = false;
}
