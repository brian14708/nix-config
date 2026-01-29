{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      imports = [ nixos.desktop-common ];

      programs.niri.enable = true;
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        configPackages = [ pkgs.niri ];
      };
    };
}
