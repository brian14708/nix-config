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
  imports = [
    inputs.nix-darwin.flakeModules.default
  ];

  flake-file.inputs.nix-darwin = {
    url = "github:nix-darwin/nix-darwin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.darwinConfigurations = lib.pipe config.flake.modules.darwin [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module: {
        name = lib.removePrefix prefix name;
        value = inputs.nix-darwin.lib.darwinSystem {
          modules = [ module ];
        };
      }
    ))
  ];
}
