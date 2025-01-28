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
    ../../features/desktop/hyprland.nix
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  networking = {
    hostName = "fuxi";
  };

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
}
