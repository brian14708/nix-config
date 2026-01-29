toplevel@{
  inputs,
  ...
}:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.home-manager =
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
                username = toplevel.config.flake.meta.owner.username;
                stateVersion = osConfig.system.stateVersion;
              };
            }
          )
          toplevel.config.flake.modules.homeManager."hosts/${config.networking.hostName}"
        ];
      };
    };
}
