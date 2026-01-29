toplevel@{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (config.flake.meta) owner;
in
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.workstation =
    { pkgs, config, ... }:
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
        };
        optimise.automatic = true;
        gc = {
          automatic = true;
          options = "--delete-older-than 7d";
        };
      };

      zramSwap.enable = true;
      services.tailscale = {
        enable = true;
      };

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      systemd.coredump.enable = false;
      boot.kernel.sysctl."kernel.core_pattern" = "|/run/current-system/sw/bin/false";
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

      powerManagement.enable = true;
      services.auto-cpufreq.enable = true;
      services.auto-cpufreq.settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
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
}
