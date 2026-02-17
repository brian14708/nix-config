{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/aether" =
    { pkgs, ... }:
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
    };

  flake.modules.nixos."hosts/aether" = {
    imports = with config.flake.modules.nixos; [
      workstation
      secureboot
      locale-cn
      mihomo
      niri
      intel
      stylix
      home-manager
    ];

    networking.hostName = "aether";
    system.stateVersion = "26.05";
    stylix.enable = true;

    virtualisation.podman.enable = true;
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "vmd"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    hardware.cpu.intel.npu.enable = true;

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
                      swap.swapfile.size = "48G";
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
