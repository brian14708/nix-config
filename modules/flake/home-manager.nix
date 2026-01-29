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
    homeManager.base = { };

    nixos.home-manager =
      { config, ... }:
      {
        imports = [ inputs.home-manager.nixosModules.home-manager ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${toplevel.config.flake.meta.owner.username}.imports = [
            (
              { osConfig, ... }:
              {
                home = {
                  inherit (toplevel.config.flake.meta.owner) username;
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
          users.${toplevel.config.flake.meta.owner.username}.imports = [
            {
              home = {
                inherit (toplevel.config.flake.meta.owner) username;
              };
            }
            toplevel.config.flake.modules.homeManager.base
            (toplevel.config.flake.modules.homeManager."hosts/${config.networking.hostName}" or { })
          ];
        };
      };
  };
}
