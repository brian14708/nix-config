toplevel@{
  inputs,
  ...
}:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules = {
    homeManager.base = {
      imports = [ toplevel.config.flake.modules.generic.owner ];
    };

    nixos.home-manager =
      { config, ... }:
      {
        imports = [ inputs.home-manager.nixosModules.home-manager ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${config.owner.username}.imports = [
            (
              { osConfig, ... }:
              {
                home = {
                  inherit (config.owner) username;
                  inherit (osConfig.system) stateVersion;
                };
              }
            )
            toplevel.config.flake.modules.homeManager.base
            (toplevel.config.flake.modules.homeManager."hosts/${config.networking.hostName}" or { })
          ];
        };
      };

    darwin.home-manager =
      { config, ... }:
      {
        imports = [ inputs.home-manager.darwinModules.home-manager ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${config.owner.username}.imports = [
            {
              home = {
                inherit (config.owner) username;
              };
            }
            toplevel.config.flake.modules.homeManager.base
            (toplevel.config.flake.modules.homeManager."hosts/${config.networking.hostName}" or { })
          ];
        };
      };
  };
}
