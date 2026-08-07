{
  inputs,
  config,
  ...
}:
let
  deployLib = inputs.deploy-rs.lib.x86_64-linux;

  mkNode = name: hostname: {
    inherit hostname;
    sshUser = "ops";
    profiles.system = {
      user = "root";
      path = deployLib.activate.nixos config.flake.nixosConfigurations.${name};
    };
  };
in
{
  flake-file.inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.deploy.nodes = {
    watchtower = mkNode "watchtower" "watchtower";
  };

  perSystem =
    { system, ... }:
    {
      checks = inputs.deploy-rs.lib.${system}.deployChecks config.flake.deploy;
    };
}
