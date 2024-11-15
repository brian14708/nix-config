{
  options,
  lib,
  ...
}:
{
  imports = [
    ./identity.nix
  ];
  config = lib.optionalAttrs (options ? home-manager) {
    home-manager.sharedModules = [
      ../home-manager
    ];
  };
}
