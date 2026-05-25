{
  inputs,
  config,
  ...
}:
let
  mkHost = name: deployment: {
    inherit deployment;
    imports = [
      config.flake.modules.nixos.base
      config.flake.modules.nixos."hosts/${name}"
    ];
  };
in
{
  flake-file.inputs.colmena = {
    url = "github:zhaofengli/colmena";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.colmena = {
    meta = {
      nixpkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
      };
    };

    watchtower = mkHost "watchtower" {
      targetHost = "watchtower";
      targetUser = "ops";
    };

    lab01 = mkHost "lab01" {
      targetHost = "lab01";
      targetUser = "ops";
    };
  };
}
