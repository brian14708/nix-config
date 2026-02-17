{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/fujin" =
    { pkgs, ... }:
    {
      imports = with hm; [
        workstation-linux
        cli
        catppuccin
      ];
      programs.gpg = {
        enable = true;
      };
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };
    };

  flake.modules.nixos."hosts/fujin" =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        tailscale-subnet
        amd
        stylix
        home-manager
      ];

      networking.hostName = "fujin";
      system.stateVersion = "24.11";
      stylix.enable = true;

      services = {
        tailscale = {
          useRoutingFeatures = "both";
          extraSetFlags = [
            "--advertise-exit-node"
          ];
        };
        hardware.bolt.enable = true;
      };

      virtualisation.podman.enable = true;
      hardware.graphics.enable = true;

      disko.devices = {
        disk.nvme = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "root";
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "btrfs";
                    subvolumes = {
                      "@" = { };
                      "@/root" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress=zstd"
                        ];
                      };
                      "@/home" = {
                        mountpoint = "/home";
                        mountOptions = [
                          "compress=zstd"
                        ];
                      };
                      "@/nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@/swap" = {
                        mountpoint = "/nix/swap";
                        swap.swapfile.size = "32G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
