{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/shiva" =
    { pkgs, ... }:
    {
      imports = with hm; [
        workstation-linux
        niri
        fcitx5
        media
        chromium
        vscode
        cli
        catppuccin
      ];

      home.packages = with pkgs; [ obsidian ];

      programs.gpg = {
        enable = true;
      };
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };

      wayland.windowManager.hyprland.settings = {
        env = [
          "AQ_DRM_DEVICES,/dev/dri/card1"
        ];
        monitor = [
          "eDP-1, preferred, auto, 2"
          "desc:AOC Q2790PQ PSKP5HA003512, preferred, auto, 1.6"
        ];
      };

      wayland.windowManager.niri.settings = {
        "output \"eDP-1\"".scale = 2;
        "output \"PNP(AOC) Q2790PQ PSKP5HA003512\"".scale = 1.4;
      };
    };

  flake.modules.nixos."hosts/shiva" =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        niri
        intel
        # nvidia
        stylix
        home-manager
        (config.flake.factory.disko-workstation { })
      ];

      networking.hostName = "shiva";
      system.stateVersion = "24.11";
      stylix.enable = true;
      virtualisation.docker = {
        enable = true;
      };
      users.users.brian = {
        extraGroups = [ "docker" ];
      };
      environment.systemPackages = [ pkgs.minikube ];

      services.tailscale = {
        useRoutingFeatures = "server";
        extraSetFlags = [
          "--advertise-routes=fd7a:115c:a1e0:b1a:0:1:a00:0/104,fd7a:115c:a1e0:b1a:0:1:6440:0/106"
        ];
      };
      systemd.services.tailscaled.path = [ pkgs.iputils ];
    };
}
