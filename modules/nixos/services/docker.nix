{ ... }:
{
  flake.modules.nixos.docker =
    { config, ... }:
    let
      proxyHost = "127.0.0.1";
      bridgeHost = "172.17.0.1";
      proxyPort = 7890;
      noProxy = "localhost,127.0.0.1,::1";
    in
    {
      virtualisation.docker = {
        enable = true;
        daemon.settings.proxies = {
          http-proxy = "http://${bridgeHost}:${toString proxyPort}";
          https-proxy = "http://${bridgeHost}:${toString proxyPort}";
          no-proxy = noProxy;
        };
      };

      networking.firewall.interfaces."docker0".allowedTCPPorts = [ proxyPort ];

      systemd.services.docker.environment = {
        HTTP_PROXY = "http://${proxyHost}:${toString proxyPort}";
        HTTPS_PROXY = "http://${proxyHost}:${toString proxyPort}";
        NO_PROXY = noProxy;
      };

      users.users.${config.owner.username}.extraGroups = [ "docker" ];
    };
}
