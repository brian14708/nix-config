{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.homeManager."hosts/lab01" = { };

  flake.modules.nixos."hosts/lab01" =
    { pkgs, config, ... }:
    let
      inherit (config) owner;
    in
    {
      imports = with nixos; [
        lab-aliyun
        home-manager
      ];

      networking.hostName = "lab01";
      system.stateVersion = "24.11";

      users.users.${owner.username} = {
        uid = 1000;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = owner.ssh;
        hashedPassword = "!";
      };

      environment.systemPackages = with pkgs; [
        tmux
      ];

      virtualisation.containerd.enable = true;
      networking.firewall.enable = false;
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
      };
    };
}
