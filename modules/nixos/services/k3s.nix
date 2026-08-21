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

      environment = {
        systemPackages = [ pkgs.kubectl ];
        variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      };
    };
}
