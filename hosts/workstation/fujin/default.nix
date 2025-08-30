{
  pkgs,
  ...
}:
{
  imports = [
    ../base-linux.nix
    ./disko.nix
    ../../features/locale/cn.nix
    ../../features/network/tailscale-subnet.nix
    ../../features/network/mihomo.nix
  ];

  system.stateVersion = "24.11";

  services.tailscale = {
    useRoutingFeatures = "both";
    extraSetFlags = [
      "--advertise-exit-node"
    ];
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
    package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
  };
  services.xserver.videoDrivers = [
    "nvidia"
  ];
  virtualisation.podman.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.brian = {
      imports = [
        ../../../home/brian/workstation/fujin
      ];
    };
  };
  stylix.enable = true;
}
