{
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
    hostName = "aether";
  };

  hardware.cpu.amd.updateMicrocode = true;

  system.stateVersion = "24.11";
}
