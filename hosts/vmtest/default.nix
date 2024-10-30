{
  pkgs,
  inputs,
  outputs,
  machine,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ./disko.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "mitigations=off" ];
    initrd.systemd.enable = true;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
  };

  users.mutableUsers = false;
  users.users.brian = {
    uid = 1000;
    description = "Brian";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "";
    openssh.authorizedKeys.keys = [
      "cert-authority,principals=\"me@brian14708.dev\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeS6dWCB0TwwnmL6ynrQuLr5jsqS0dwjuwgw3FLen9P1hg+PMhwyw2G7ABfogZHwNG5y2jvB5iLfclrKPDQ/B31oJeWMV5hilDIiTLPTtIqKd93QQujyyLUqznC3dYNzJC7vBr0HGcR6te90Fjk80vsfFUQ/kE3PVJVGguhZI9TX9T2JepOlyQ597NSNuNkx7GUG9vrdZwxkyC3PUu2ipyLOvmLTiRPgl0wLXoIHUTgt0GfM5KpF3tlSirrWBu9WFdfL37YDvQt7JhqmsIXuUusNRw95HlROTujjV5xgWmv59t7TIdWRO3M2wzNQ257Wd3TZXmoYyk5TSzLvIWXb9dW0KlK4u8xaK0CU/H4Ro30coWveujmCX3jAxfAFpCSDHsy79JX/MIi43HnLJjvBY+1/VCwKwGUyXajq8/5XOCdBYYcQcNzfvWPoA2j8VlkxgaMHQ7i5tUy2dAHzKdJDmfuSyDrHEzfgGpAna8NaRbH5WKMpxX7dmlgmI0kWOw1nojfC8CCJyfEYPS81b7m9Z65C0+m+zhruUY9A/v3MdmwHlnkMMFmLHaavJSxK1U1ROGs/MYEiauBZiYiFPXbJnDNrU7hujTwdXvO5adJO8oZ9byOazB09vnRNQgc/X6hIas2Fh13tQ8NMbqZGWLcmfH6LkdjrVloRbbV7QtU0GCGQ=="
    ];
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.brian = {
    imports = [ ../../home/brian/generic.nix ];
  };
  home-manager.extraSpecialArgs = {
    inherit inputs outputs machine;
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

  programs.fish.enable = true;
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 6;
      graphics = true;
    };

    virtualisation.forwardPorts = [
      {
        from = "host";
        guest.port = 22;
        host.port = 2222;
      }
    ];

    virtualisation.qemu.options = [
      "-vga qxl"
    ];
  };

  services.xserver.enable = true;
  services.displayManager.autoLogin.user = "brian";
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.enableScreensaver = false;
}
