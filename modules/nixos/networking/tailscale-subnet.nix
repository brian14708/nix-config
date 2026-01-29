{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.tailscale-subnet =
    { config, lib, ... }:
    {
      imports = [ nixos.sops ];

      services.tailscale = {
        useRoutingFeatures = lib.mkDefault "client";
        extraSetFlags = [
          "--accept-routes"
        ];
      };

      services.unbound = {
        enable = true;
        settings.include = config.sops.secrets."configs/unbound".path;
      };
    };
}
