{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    ../base
  ];

  services.dbus.implementation = "broker";
  services.speechd.enable = false;
  zramSwap.enable = true;
}
