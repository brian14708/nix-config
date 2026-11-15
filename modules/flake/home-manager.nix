toplevel@{
  inputs,
  ...
}:
let
  hm = toplevel.config.flake.modules.homeManager;
  mkHomeManager = host: home: {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${host.owner.username} = {
      imports = [
        hm.base
        (hm."hosts/${host.networking.hostName}" or { })
      ];
      home = {
        inherit (host.owner) username;
      }
      // home;
    };
  };
in
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules = {
    homeManager.base =
      { lib, ... }:
      {
        imports = [ toplevel.config.flake.modules.generic.owner ];
        home.enableNixpkgsReleaseCheck = lib.mkDefault false;
      };

    nixos.home-manager =
      { config, ... }:
      {
        imports = [ inputs.home-manager.nixosModules.home-manager ];

        home-manager = mkHomeManager config {
          inherit (config.system) stateVersion;
        };
      };

    darwin.home-manager =
      { config, ... }:
      {
        imports = [ inputs.home-manager.darwinModules.home-manager ];

        home-manager = mkHomeManager config { };
      };
  };
}
