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
    package = pkgs.linuxPackages_latest.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [
    "mesa"
    "nvidia"
  ];
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
