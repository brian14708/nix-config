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
  hardware.nvidia = {
    open = true;
    package = pkgs.linuxPackages_latest.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [
    "nvidia"
    "mesa"
  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}
