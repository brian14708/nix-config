{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/fuxi" =
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

      wayland.windowManager.niri.settings = {
        debug.render-drm-device = "/dev/dri/renderD129";
        "output \"eDP-1\"".scale = 2.0;
        "output \"Dell Inc. DELL D2720DS 8QHGNS2\"".scale = 1.5;
      };
    };

  flake.modules.nixos."hosts/fuxi" =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        tailscale-subnet
        niri
        amd
        # nvidia
        stylix
        home-manager
      ];

      networking.hostName = "fuxi";
      system.stateVersion = "24.11";
      stylix.enable = true;

      boot = {
        kernelParams = [ "resume_offset=533760" ];
        resumeDevice = "/dev/mapper/root";
        kernelPatches = [
          {
            name = "Disable OOBE mode on the ProArt PX13";
            patch = ./fuxi/kernel/HID-hid-asus-Disable-OOBE-mode-on-the-ProArt-PX13.patch;
          }
        ];
      };

      environment.sessionVariables = {
        VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
        __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
      };
      hardware.nvidia.prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        nvidiaBusId = "pci:196:0:0";
        amdgpuBusId = "pci:197:0:0";
      };
      boot.extraModprobeConfig = ''
        blacklist nvidia
        blacklist nvidia-uvm
        blacklist nvidia-drm
        options nvidia_drm modeset=1 fbdev=1
      '';
      users.users.brian.extraGroups = [ "dialout" ];

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
