{
  config,
  ...
}:
{
  imports = [
    ./disko.nix
    ../profiles/desktop.nix
    ../features/locale/cn.nix
    ../features/network/mihomo.nix
  ];

  system.stateVersion = "24.11";

  boot =
    {
    };

  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  networking = {
    hostName = "fujin";
  };

  hardware.cpu.amd.updateMicrocode = true;
  services.hardware.bolt.enable = true;
  hardware.nvidia.open = true;
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];
}
