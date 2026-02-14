{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/shiva" =
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

      programs.gpg = {
        enable = true;
      };
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
          "eDP-1, preferred, auto, 2"
          "desc:AOC Q2790PQ PSKP5HA003512, preferred, auto, 1.6"
        ];
      };

      wayland.windowManager.niri.settings = {
        "output \"eDP-1\"".scale = 2;
        "output \"PNP(AOC) Q2790PQ PSKP5HA003512\"".scale = 1.4;
      };
    };

  flake.modules.nixos."hosts/shiva" =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        niri
        intel
        # nvidia
        stylix
        home-manager
      ];

      networking.hostName = "shiva";
      system.stateVersion = "24.11";
      stylix.enable = true;
      virtualisation.docker = {
        enable = true;
      };
      users.users.brian = {
        extraGroups = [ "docker" ];
      };
      environment.systemPackages = [ pkgs.minikube ];

      services.tailscale = {
        useRoutingFeatures = "server";
        extraSetFlags = [
          "--advertise-routes=fd7a:115c:a1e0:b1a:0:1:a00:0/104,fd7a:115c:a1e0:b1a:0:1:6440:0/106"
        ];
      };
      systemd.services.tailscaled.path = [ pkgs.iputils ];

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
