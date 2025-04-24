{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.qalculate;
in
{
  options.programs.qalculate = with types; {
    enable = mkEnableOption "qalculate";

    gui = {
      enable = mkOption {
        type = bool;
        default = false;
      };
      package = mkOption {
        type = nullOr package;
        default = pkgs.qalculate-gtk;
      };
    };

    cli = {
      enable = mkOption {
        type = bool;
        default = true;
      };
      package = mkOption {
        type = nullOr package;
        default = pkgs.libqalculate;
      };
    };

    definitions = mkOption {
      type = attrsOf path;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (optional (cfg.gui.enable && cfg.gui.package != null) cfg.gui.package)
      ++ (optional (cfg.cli.enable && cfg.cli.package != null) cfg.cli.package);

    xdg.dataFile = lib.mapAttrs' (
      name: file: lib.nameValuePair "qalculate/definitions/${name}.xml" { source = file; }
    ) cfg.definitions;
  };
}
