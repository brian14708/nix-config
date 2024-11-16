{
  options,
  lib,
  ...
}:
{
  imports = [
    ./userinfos.nix
  ];
  config = lib.optionalAttrs (options ? home-manager) {
    home-manager.sharedModules = [
      ../home-manager
    ];
  };
}
