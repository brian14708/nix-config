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
    hostName = "styx";
  };

  hardware.cpu.intel.updateMicrocode = true;
  system.stateVersion = "24.11";
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
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
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.brian = {
      imports = [
        ../../../home/brian/workstation/styx
      ];
    };
  };
}
