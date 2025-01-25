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
  ];

  system.stateVersion = "24.11";

  boot = {
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  networking = {
    hostName = "fujin";
  };

  hardware.cpu.amd.updateMicrocode = true;
  services.hardware.bolt.enable = true;
  hardware.graphics = {
    enable = true;
  };
  hardware.nvidia = {
    open = true;
    package = pkgs.linuxPackages_latest.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [
    "nvidia"
  ];
  virtualisation.podman.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
}
