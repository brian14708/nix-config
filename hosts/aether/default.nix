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
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    ./disko.nix
    ./mihomo.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
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
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets."brian-password" = {
      neededForUsers = true;
    };
    secrets."mihomo-url" = { };
  };

  networking = {
    hostName = "aether";
    networkmanager.enable = false;
    useDHCP = false;
    wireless.iwd.enable = true;
  };
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
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "cert-authority,principals=\"me@brian14708.dev\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeS6dWCB0TwwnmL6ynrQuLr5jsqS0dwjuwgw3FLen9P1hg+PMhwyw2G7ABfogZHwNG5y2jvB5iLfclrKPDQ/B31oJeWMV5hilDIiTLPTtIqKd93QQujyyLUqznC3dYNzJC7vBr0HGcR6te90Fjk80vsfFUQ/kE3PVJVGguhZI9TX9T2JepOlyQ597NSNuNkx7GUG9vrdZwxkyC3PUu2ipyLOvmLTiRPgl0wLXoIHUTgt0GfM5KpF3tlSirrWBu9WFdfL37YDvQt7JhqmsIXuUusNRw95HlROTujjV5xgWmv59t7TIdWRO3M2wzNQ257Wd3TZXmoYyk5TSzLvIWXb9dW0KlK4u8xaK0CU/H4Ro30coWveujmCX3jAxfAFpCSDHsy79JX/MIi43HnLJjvBY+1/VCwKwGUyXajq8/5XOCdBYYcQcNzfvWPoA2j8VlkxgaMHQ7i5tUy2dAHzKdJDmfuSyDrHEzfgGpAna8NaRbH5WKMpxX7dmlgmI0kWOw1nojfC8CCJyfEYPS81b7m9Z65C0+m+zhruUY9A/v3MdmwHlnkMMFmLHaavJSxK1U1ROGs/MYEiauBZiYiFPXbJnDNrU7hujTwdXvO5adJO8oZ9byOazB09vnRNQgc/X6hIas2Fh13tQ8NMbqZGWLcmfH6LkdjrVloRbbV7QtU0GCGQ=="
    ];
    hashedPasswordFile = config.sops.secrets."brian-password".path;
  };

  environment.systemPackages = with pkgs; [
    git
    gnumake
    tmux
  ];

  hardware.enableRedistributableFirmware = true;
  time.timeZone = "Asia/Hong_Kong";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      extraUpFlags = [ "--accept-routes" ];
    };
  };

  system.stateVersion = "24.11";

  nix = {
    package = pkgs.lix;
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
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

  services.dbus.implementation = "broker";
}
