{
  config,
  ...
}:
{
  services.tailscale = {
    useRoutingFeatures = "client";
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
