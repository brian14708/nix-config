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
      nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    };

    watchtower = mkHost "watchtower" {
      targetHost = "watchtower";
      targetUser = "ops";
    };

    omniagent = mkHost "omniagent" {
      targetHost = "ssh.omni-agent.xyz";
      targetPort = 22;
      targetUser = "ops";
    };
  };
}
