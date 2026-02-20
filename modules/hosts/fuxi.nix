{ config, inputs, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/fuxi" =
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

      wayland.windowManager.niri.settings = {
        debug.render-drm-device = "/dev/dri/renderD129";
        "output \"eDP-1\"".scale = 2.0;
        "output \"Dell Inc. DELL D2720DS 8QHGNS2\"".scale = 1.5;
        "output \"Invalid Vendor Codename - RTK Monitor Unknown\"".scale = 3;
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
        (config.flake.factory.disko-workstation { })
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
            patch = inputs.self + /configs/HID-hid-asus-Disable-OOBE-mode-on-the-ProArt-PX13.patch;
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
    };
}
