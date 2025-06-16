{ pkgs, ... }:
{
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
