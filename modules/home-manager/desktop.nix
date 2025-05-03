{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.desktop;
in
{
  options.my.desktop = {
    enable = lib.mkEnableOption "Enable desktop features";
    startupCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of shell commands to run at desktop startup";
    };

    wallpaper = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    my.desktop.startupCommands = [
      "${pkgs.swaybg}/bin/swaybg -i ${cfg.wallpaper}"
    ];
  };
}
