{ config, ... }:
let
  inherit (config.flake.modules) homeManager nixos;
in
{
  flake.modules.homeManager."hosts/styx" =
    { pkgs, lib, ... }:
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

      # Lock screen immediately on startup (autologin + lock = secure remote access)
      wayland.windowManager.niri.spawnAtStartup = [ (lib.getExe pkgs.hyprlock) ];

      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };
    };

  flake.modules.nixos."hosts/styx" =
    { lib, pkgs, ... }:
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

      services.sunshine = {
        enable = true;
        capSysAdmin = true;
        openFirewall = true;
      };

      # Autologin for remote access (Sunshine needs a running session)
      services.greetd.settings.default_session = {
        command = lib.mkForce "${pkgs.niri}/bin/niri-session";
        user = lib.mkForce "brian";
      };

      virtualisation.podman.enable = true;
    };
}
