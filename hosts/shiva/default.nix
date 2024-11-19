{
  config,
  ...
}:
{
  imports = [
    ./disko.nix
    ../profiles/workstation
    ../features/locale/cn.nix
    ../features/network/mihomo.nix
    ../features/desktop/hyprland.nix
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  networking = {
    hostName = "shiva";
  };

  hardware.cpu.intel.updateMicrocode = true;

  system.stateVersion = "24.11";
}
