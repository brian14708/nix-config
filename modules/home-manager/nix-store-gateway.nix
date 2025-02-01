{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.services.nix-store-gateway;
  pkg = pkgs.nix-store-gateway;
in
{
  options.services.nix-store-gateway = {
    enable = mkEnableOption "Nix store gateway";
    config = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.int;
      default = 4444;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.nix-store-gateway = {
      Service = {
        ExecStartPre = ''/bin/sh -c 'while [ ! -f ${cfg.config} ]; do sleep 1; done' '';
        Restart = "on-failure";
        ExecStart = "${pkg}/bin/nix-store-gateway [::1]:${toString cfg.port} ${cfg.config}";
      };
      Install.WantedBy = [ "default.target" ];
    };
    nix.settings = {
      substituters = lib.mkBefore [
        "http://[::1]:${toString cfg.port}"
      ];
      fallback = true;
    };
  };
}
