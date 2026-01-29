{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
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
