{
  inputs,
  lib,
  config,
  ...
}:
let
  owner = config.flake.meta.owner;
in
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.base =
    { pkgs, config, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];

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

      users.users = {
        root.hashedPassword = "!";
      };

      users.users."${owner.username}" = {
        uid = 1000;
        description = owner.name;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "video"
        ];
        openssh.authorizedKeys.keys = owner.ssh;
        # hashedPasswordFile = config.sops.secrets."brian/password".path;
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

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-session";
            user = "greeter";
          };
        };
      };

      environment.etc = {
        "chromium/policies/managed/extra.json" = {
          text = builtins.toJSON {
            DnsOverHttpsMode = "off";
            SafeBrowsingProtectionLevel = 0;
            TranslateEnabled = false;
          };
        };
      };
    };
}
