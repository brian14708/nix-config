toplevel@{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.workstation =
    { pkgs, config, ... }:
    let
      inherit (config) owner;
    in
    {
      imports = with toplevel.config.flake.modules.nixos; [
        inputs.disko.nixosModules.disko
        sops
        comma
      ];

      # Host-specific secrets for workstation machines.
      sops.secrets = {
        "hosts/${config.networking.hostName}/password" = {
          neededForUsers = true;
        };
        "hosts/${config.networking.hostName}/ssh" = {
          owner = owner.username;
          path = "/home/${owner.username}/.ssh/id_ed25519";
          mode = "0600";
        };
        "hosts/${config.networking.hostName}/sops" = {
          owner = owner.username;
          path = "/home/${owner.username}/.config/sops/age/keys.txt";
          mode = "0600";
        };
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      boot = {
        # Personal machine with controlled workloads — accept the Spectre/Meltdown tradeoff for performance.
        kernelParams = [ "mitigations=off" ];
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      };
      programs.nix-ld.enable = true;

      services = {
        dbus.implementation = "broker";
        speechd.enable = false;
        openssh.enable = true;
      };

      users = {
        mutableUsers = false;
        users = {
          root.hashedPassword = "!";
          "${owner.username}" = {
            uid = 1000;
            description = owner.name;
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "video"
            ];
            openssh.authorizedKeys.keys = owner.ssh;
            hashedPasswordFile = config.sops.secrets."hosts/${config.networking.hostName}/password".path;
          };
        };
      };

      nix = {
        package = pkgs.nixVersions.latest;
        channel.enable = false;
        nixPath = [ "nixpkgs=${pkgs.path}" ];
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [ owner.username ];
          max-jobs = "auto";
        };
        optimise.automatic = true;
        gc = {
          automatic = true;
          options = "--delete-older-than 14d";
        };
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };
      services.tailscale = {
        enable = true;
      };

      services.scx = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        enable = true;
        scheduler = "scx_lavd";
      };
      systemd.oomd = {
        enable = true;
        enableUserSlices = true;
      };
      services.fstrim.enable = true;

      services.journald.extraConfig = ''
        SystemMaxUse=500M
        MaxRetentionSec=2w
      '';

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      systemd.coredump.enable = false;
      boot.tmp.cleanOnBoot = true;
      boot.kernelModules = [ "tcp_bbr" ];
      boot.kernel.sysctl = {
        "kernel.core_pattern" = "|/run/current-system/sw/bin/false";
        "vm.swappiness" = 180;
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
      networking.networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      networking.firewall.trustedInterfaces = [
        config.services.tailscale.interfaceName
      ];

      hardware.enableRedistributableFirmware = true;
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "lock";
      };
      services.chrony = {
        enable = true;
      };

      services.tlp = {
        enable = true;
        settings = {
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_BOOST_ON_BAT = 0;
        };
      };
      documentation = {
        dev.enable = true;
        man = {
          man-db.enable = false;
          mandoc.enable = true;
        };
      };
      environment.systemPackages = with pkgs; [
        ghostty.terminfo
        foot.terminfo
        man-pages
        man-pages-posix
      ];
    };

  flake.modules.darwin.workstation =
    { config, ... }:
    let
      inherit (config) owner;
    in
    {
      sops.secrets = {
        "hosts/${config.networking.hostName}/sops" = {
          owner = owner.username;
          path = "/Users/${owner.username}/.config/sops/age/keys.txt";
          mode = "0600";
        };
      };
    };
}
