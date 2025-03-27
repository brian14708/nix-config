{
  pkgs,
  ...
}:
{
  imports = [
    ../base-linux.nix
    ./disko.nix
    ../../features/locale/cn.nix
    ../../features/network/mihomo.nix
    ../../features/network/tailscale-subnet.nix
    ../../features/desktop/hyprland.nix
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  networking = {
    hostName = "fuxi";
  };

  boot.kernelPatches = [
    {
      patch = pkgs.fetchurl {
        url = "https://lore.kernel.org/linux-wireless/20250305000851.493671-1-sean.wang@kernel.org/t.mbox.gz";
        hash = "sha256-3hXrLJ0BwMscrzxpzomsqCqzKx/V4msaAw65HtoSaPE=";
      };
    }
    {
      patch = ./HID-hid-asus-Disable-OOBE-mode-on-the-ProArt-PX13.patch;
    }
  ];

  system.stateVersion = "24.11";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.nvidia = {
    open = true;
    package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
  };
  services.xserver.videoDrivers = [
    "mesa"
    "nvidia"
  ];
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
  networking.networkmanager.wifi.backend = "iwd";
}
