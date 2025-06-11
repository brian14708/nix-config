{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./userinfos.nix
    ./boot/secureboot.nix
  ];
  config = {
    stylix.base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
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
