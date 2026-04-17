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

      # Lock screen immediately on startup (autologin + lock = secure remote access)
      wayland.windowManager.niri.spawnAtStartup = [ "${pkgs.hyprlock}/bin/hyprlock" ];

      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };
    };

  flake.modules.nixos."hosts/styx" =
    { lib, pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
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
