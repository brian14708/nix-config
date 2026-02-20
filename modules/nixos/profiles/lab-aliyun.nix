{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.lab-aliyun =
    {
      pkgs,
      lib,
      config,
      modulesPath,
      ...
    }:
    let
      inherit (config) owner;
    in
    {
      imports = [
        (modulesPath + "/profiles/minimal.nix")
        (modulesPath + "/profiles/headless.nix")
        (modulesPath + "/profiles/qemu-guest.nix")
        nixos.locale-cn
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      system.stateVersion = lib.mkDefault "24.11";

      # Roughly mirrors nix.orig's `hosts/profiles/linux.nix` baseline.
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      documentation.doc.enable = false;
      programs.nix-ld.enable = true;
      nix.settings = {
        trusted-users = [ "@wheel" ];
        allowed-users = [ "@users" ];
      };

      services = {
        dbus.implementation = "broker";
        speechd.enable = false;
        openssh.enable = true;

        tailscale = {
          enable = true;
          authKeyFile = "/var/secrets/tailscale_key";
        };

        cloud-init = {
          enable = true;
          settings.datasource_list = [ "AliYun" ];
        };

        chrony.enable = true;
      };

      nix = {
        package = pkgs.nixVersions.latest;
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        optimise.automatic = true;
        gc = {
          automatic = true;
          options = "--delete-older-than 7d";
        };
      };

      networking.firewall.trustedInterfaces = [
        config.services.tailscale.interfaceName
      ];
      systemd.services.tailscaled-autoconnect.after = [ "cloud-final.service" ];

      users = {
        mutableUsers = false;
        users = {
          root.hashedPassword = "!";
          ops = {
            uid = 2000;
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = owner.ssh;
          };
        };
      };

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

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        autoResize = true;
        fsType = "ext4";
      };

      boot = {
        growPartition = true;
        kernelParams = [ "console=ttyS0" ];
        loader = {
          grub = {
            device =
              if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
                lib.mkDefault "/dev/vda"
              else
                lib.mkDefault "nodev";
            efiSupport = lib.mkIf (pkgs.stdenv.hostPlatform.system != "x86_64-linux") (lib.mkDefault true);
            efiInstallAsRemovable = lib.mkIf (pkgs.stdenv.hostPlatform.system != "x86_64-linux") (
              lib.mkDefault true
            );
          };
          timeout = 0;
        };
      };

      system.build.qcow2 = import "${toString modulesPath}/../lib/make-disk-image.nix" {
        inherit lib config pkgs;
        diskSize = "auto";
        format = "qcow2-compressed";
        partitionTableType = "hybrid";
      };

      environment.systemPackages = with pkgs; [
        rsync
        ghostty.terminfo
      ];
    };
}
