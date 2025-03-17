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
    hostName = "shiva";
  };

  hardware.cpu.intel.updateMicrocode = true;
  system.stateVersion = "24.11";
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      intel-compute-runtime
      intel-media-driver
    ];
  };
  hardware.nvidia = {
    open = true;
    package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
  };
  services.xserver.videoDrivers = [
    "nvidia"
    "mesa"
  ];
  virtualisation.podman = {
    enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
  };
}
