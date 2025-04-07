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
  virtualisation.docker = {
    enable = true;
  };
  users.users.brian = {
    extraGroups = [ "docker" ];
  };
  environment.systemPackages = [ pkgs.minikube ];
  hardware.nvidia-container-toolkit.enable = true;

  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-routes=fd7a:115c:a1e0:b1a:0:1:a00:0/104,fd7a:115c:a1e0:b1a:0:1:6440:0/106"
    ];
  };
}
