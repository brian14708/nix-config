{
  flake.modules.homeManager.base =
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
          # Structured argv form so consumers (niri/hyprland/...) don't have to
          # guess how to split/quote.
          type = lib.types.listOf (lib.types.listOf lib.types.str);
          default = [ ];
          description = "List of argv commands to run at desktop startup";
        };

        wallpaper = lib.mkOption {
          type = lib.types.path;
        };
      };

      config = lib.mkIf cfg.enable {
        my.desktop.startupCommands = [
          [
            "${pkgs.swaybg}/bin/swaybg"
            "-i"
            "${cfg.wallpaper}"
          ]
        ];
      };
    };
}
