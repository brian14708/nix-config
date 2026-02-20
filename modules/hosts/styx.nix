{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/styx" =
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

      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };

      wayland.windowManager.hyprland.settings = {
        env = [
          "AQ_DRM_DEVICES,/dev/dri/card1"
        ];
        monitor = [
          "desc:AOC Q2790PQ PSKP5HA003512, 2560x1440, auto, 1.6"
          "eDP-1, preferred, auto, 2"
        ];
        bindl = [
          ''switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, preferred, auto, auto"''
          ''switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"''
        ];
      };
    };

  flake.modules.nixos."hosts/styx" =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        niri
        intel
        nvidia
        stylix
        home-manager
        (config.flake.factory.disko-workstation { })
      ];

      networking.hostName = "styx";
      system.stateVersion = "24.11";
      stylix.enable = true;

      virtualisation.podman.enable = true;
      hardware.nvidia-container-toolkit.enable = true;
    };
}
