{ config, ... }:
let
  inherit (config.flake.modules) homeManager nixos;
in
{
  flake.modules.homeManager."hosts/styx" =
    { pkgs, ... }:
    {
      imports = with homeManager; [
        workstation-linux
        niri
        fcitx5
        media
        chromium
        vscode
        cli
        catppuccin
      ];

      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };
    };

  flake.modules.nixos."hosts/styx" =
    { pkgs, ... }:
    {
      imports = with nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        niri
        intel
        stylix
        home-manager
        (config.flake.factory.disko-workstation {
          diskName = "sda";
          device = "/dev/sda";
        })
      ];

      networking.hostName = "styx";
      system.stateVersion = "26.05";
      stylix.enable = true;

      services.tailscale = {
        useRoutingFeatures = "server";
        extraSetFlags = [
          "--advertise-routes=fd7a:115c:a1e0:b1a:0:1:a00:0/104,fd7a:115c:a1e0:b1a:0:1:6440:0/106"
        ];
      };
      systemd.services.tailscaled.path = [ pkgs.iputils ];

      virtualisation.podman.enable = true;
    };
}
