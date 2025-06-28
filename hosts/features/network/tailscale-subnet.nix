{
  config,
  lib,
  ...
}:
{
  services.tailscale = {
    useRoutingFeatures = lib.mkDefault "client";
    extraSetFlags = [
      "--accept-routes"
    ];
  };
  services.unbound = {
    enable = true;
    settings = {
      include = config.sops.secrets."unbound".path;
    };
  };
}
