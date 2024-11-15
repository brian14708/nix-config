{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./identity.nix
    ./nix.nix
  ];
}
