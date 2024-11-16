{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    ../base
  ];

  services.dbus.implementation = "broker";
  services.speechd.enable = false;
  zramSwap.enable = true;

  sops = {
    age.sshKeyPaths = [ ];
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    gnupg.sshKeyPaths = [ ];
  };
}
