{
  config,
  pkgs,
  inputs,
  outputs,
  machine,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    "${inputs.home-manager}/nixos"
    ./disko.nix
    ./mihomo.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];
  boot.initrd.systemd.enable = true;
  boot.loader = {
    systemd-boot = {
      enable = false;
      configurationLimit = 5;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  sops = {
    defaultSopsFile = ./secret.yaml;
    age.sshKeyPaths = [ "/nix/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets."brian-password" = {
      neededForUsers = true;
    };
    secrets."mihomo-url" =
      {
      };
  };

  networking.hostName = "aether";
  networking.networkmanager.enable = false;
  networking.useDHCP = false;
  networking.wireless.iwd.enable = true;
  systemd.network.enable = true;
  systemd.network.networks."20-wireless" = {
    matchConfig.Type = "wlan";
    networkConfig.DHCP = "yes";
    dhcpV4Config.RouteMetric = 20;
    ipv6AcceptRAConfig.RouteMetric = 20;
  };

  users.mutableUsers = false;
  users.users.brian = {
    uid = 1000;
    description = "Brian";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "cert-authority,principals=\"me@brian14708.dev\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeS6dWCB0TwwnmL6ynrQuLr5jsqS0dwjuwgw3FLen9P1hg+PMhwyw2G7ABfogZHwNG5y2jvB5iLfclrKPDQ/B31oJeWMV5hilDIiTLPTtIqKd93QQujyyLUqznC3dYNzJC7vBr0HGcR6te90Fjk80vsfFUQ/kE3PVJVGguhZI9TX9T2JepOlyQ597NSNuNkx7GUG9vrdZwxkyC3PUu2ipyLOvmLTiRPgl0wLXoIHUTgt0GfM5KpF3tlSirrWBu9WFdfL37YDvQt7JhqmsIXuUusNRw95HlROTujjV5xgWmv59t7TIdWRO3M2wzNQ257Wd3TZXmoYyk5TSzLvIWXb9dW0KlK4u8xaK0CU/H4Ro30coWveujmCX3jAxfAFpCSDHsy79JX/MIi43HnLJjvBY+1/VCwKwGUyXajq8/5XOCdBYYcQcNzfvWPoA2j8VlkxgaMHQ7i5tUy2dAHzKdJDmfuSyDrHEzfgGpAna8NaRbH5WKMpxX7dmlgmI0kWOw1nojfC8CCJyfEYPS81b7m9Z65C0+m+zhruUY9A/v3MdmwHlnkMMFmLHaavJSxK1U1ROGs/MYEiauBZiYiFPXbJnDNrU7hujTwdXvO5adJO8oZ9byOazB09vnRNQgc/X6hIas2Fh13tQ8NMbqZGWLcmfH6LkdjrVloRbbV7QtU0GCGQ=="
    ];
    hashedPasswordFile = config.sops.secrets."brian-password".path;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    gnumake
    tmux
  ];

  hardware.enableRedistributableFirmware = true;
  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--accept-routes" ];
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
        "https://nix-community.cachix.org"
        "https://mirrors.cernet.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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

  environment.persistence.default = {
    persistentStoragePath = "/nix/persist";
    hideMounts = true;

    directories = [
      "/etc/secureboot"
      "/var/lib/iwd"
      "/var/lib/tailscale"
      "/var/lib/nixos"
      "/var/log"
      "/var/lib/systemd/coredump"
      {
        directory = "/var/lib/private/mihomo";
        mode = "0700";
        defaultPerms = {
          mode = "0700";
        };
      }
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];

    users.brian = {
      directories = [
        "nixos"
        "public"
        "media"
        "downloads"
        "documents"
        "projects"
        ".ssh"
      ];
    };
  };
  fileSystems."/nix/persist".neededForBoot = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs machine;
  };
  home-manager.users.brian = {
    imports = [ ../../home/brian/aether.nix ];
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  security.sudo.extraConfig = "Defaults lecture = never";
}
