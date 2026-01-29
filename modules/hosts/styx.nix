{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/styx" =
    { pkgs, config, ... }:
    {
      imports = with hm; [
        workstation-linux
        niri
        fcitx5
        media
        chromium
        vscode
        cli
        catppuccin
      ];

      home.packages = with pkgs; [ obsidian ];

      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };

      services.nix-store-gateway = {
        enable = true;
        config = config.sops.secrets."configs/nix-store-gateway".path;
      };

      wayland.windowManager.hyprland.settings = {
        env = [
          "AQ_DRM_DEVICES,/dev/dri/card1"
        ];
        monitor = [
          "desc:AOC Q2790PQ PSKP5HA003512, 2560x1440, auto, 1.6"
          "eDP-1, preferred, auto, 2"
        ];
        bindl = [
          ''switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, preferred, auto, auto"''
          ''switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"''
        ];
      };
    };

  flake.modules.nixos."hosts/styx" =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        niri
        intel
        nvidia
        stylix
        home-manager
      ];

      networking.hostName = "styx";
      system.stateVersion = "24.11";
      stylix.enable = true;

      virtualisation.podman.enable = true;
      hardware.nvidia-container-toolkit.enable = true;

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
                  settings.allowDiscards = true;
                  content = {
                    type = "btrfs";
                    subvolumes = {
                      "@" = { };
                      "@/root" = {
                        mountpoint = "/";
                        mountOptions = [ "compress=zstd" ];
                      };
                      "@/home" = {
                        mountpoint = "/home";
                        mountOptions = [ "compress=zstd" ];
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
