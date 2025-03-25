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
  services.coredns = {
    enable = true;
    config = ''
      import ${config.sops.secrets."coredns".path}
    '';
  };
}
