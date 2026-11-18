{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.tailnet-ssh =
    { config, ... }:
    {
      # Let the host enforce its input policy even when Tailscale accepts traffic.
      networking.nftables.enable = true;
      networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ 22 ];
      services.tailscale.openFirewall = true;
    };

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

      sops.secrets."configs/unbound" = {
        owner = config.services.unbound.user;
        group = config.services.unbound.group;
        restartUnits = [ "unbound.service" ];
      };
    };
}
