{
  inputs,
  lib,
  config,
  ...
}:
let
  prefix = "hosts/";
in
{
  flake.modules.nixos.base = { };
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module: {
        name = lib.removePrefix prefix name;
        value = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            config.flake.modules.nixos.base
            module
          ];
        };
      }
    ))
  ];
}
