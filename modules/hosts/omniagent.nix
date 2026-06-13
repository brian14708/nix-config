{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.homeManager."hosts/omniagent" = { };

  flake.modules.nixos."hosts/omniagent" =
    {
      pkgs,
      config,
      ...
    }:
    let
      inherit (config) owner;
    in
    {
      imports = with nixos; [
        lab-aliyun
        home-manager
      ];

      networking.hostName = "omniagent";
      system.stateVersion = "24.11";

      users.users.${owner.username} = {
        uid = 1000;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = owner.ssh;
        hashedPassword = "!";
      };

      services.k3s = {
        enable = true;
        role = "server";
        clusterInit = true;
        extraFlags = [
          "--write-kubeconfig-mode=0644"
        ];
      };

      networking.firewall.enable = false;
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
      };

      environment = {
        variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
        systemPackages = with pkgs; [
          kubectl
          helm
        ];
      };
    };
}
