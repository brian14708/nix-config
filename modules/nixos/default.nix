{
  inputs,
  options,
  lib,
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
  config = lib.optionalAttrs (options ? home-manager) {
    home-manager.sharedModules = [
      ../home-manager
    ];
  };
}
