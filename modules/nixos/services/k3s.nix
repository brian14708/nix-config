{ ... }:
{
  flake.modules.nixos.k3s =
    {
      pkgs,
      ...
    }:
    {
      services.k3s = {
        enable = true;
        role = "server";
        # Keep the single-node installation small while retaining core
        # networking and DNS for ordinary workloads.
        disable = [
          "local-storage"
          "metrics-server"
          "servicelb"
          "traefik"
        ];
        extraFlags = [ "--write-kubeconfig-mode=0644" ];
      };

      systemd.services.k3s = {
        after = [ "mihomo.service" ];
        wants = [ "mihomo.service" ];
        environment = {
          HTTP_PROXY = "http://127.0.0.1:7890";
          HTTPS_PROXY = "http://127.0.0.1:7890";
          NO_PROXY = "127.0.0.1,localhost,::1,.svc,.cluster.local,10.42.0.0/16,10.43.0.0/16";
          http_proxy = "http://127.0.0.1:7890";
          https_proxy = "http://127.0.0.1:7890";
          no_proxy = "127.0.0.1,localhost,::1,.svc,.cluster.local,10.42.0.0/16,10.43.0.0/16";
        };
      };

      environment = {
        systemPackages = [ pkgs.kubectl ];
        variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      };
    };
}
