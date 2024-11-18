{
  options,
  lib,
  ...
}:
{
  imports = [
    ./userinfos.nix
    ./boot/secureboot.nix
  ];
  config = lib.optionalAttrs (options ? home-manager) {
    home-manager.sharedModules = [
      ../home-manager
    ];
  };
}
