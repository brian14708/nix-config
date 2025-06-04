{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager

    ./userinfos.nix
    ./boot/secureboot.nix
  ];
  config = {
    home-manager = {
      sharedModules = [
        ../home-manager
      ];
      extraSpecialArgs = {
        inherit inputs outputs;
      };
    };
  };
}
