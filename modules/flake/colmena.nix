{
  inputs,
  config,
  ...
}:
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

    watchtower = {
      deployment = {
        targetHost = "watchtower";
        targetUser = "ops";
      };
      imports = [
        config.flake.modules.nixos.base
        config.flake.modules.nixos."hosts/watchtower"
      ];
    };

    lab01 = {
      deployment = {
        targetHost = "lab01";
        targetUser = "ops";
      };
      imports = [
        config.flake.modules.nixos.base
        config.flake.modules.nixos."hosts/lab01"
      ];
    };
  };
}
