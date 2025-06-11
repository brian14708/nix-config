{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-session";
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
