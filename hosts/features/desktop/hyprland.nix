{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember-session";
        user = "greeter";
      };
    };
  };

  hardware.graphics = {
    enable = true;
  };

  programs.niri.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    configPackages = [ pkgs.niri ];
  };

  environment.etc = {
    "chromium/policies/managed/extra.json" = {
      text = builtins.toJSON {
        DnsOverHttpsMode = "off";
        SafeBrowsingProtectionLevel = 0;
        TranslateEnabled = false;
      };
    };
  };
}
