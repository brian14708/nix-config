{
  flake.modules.homeManager.base =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.programs.qalculate;
    in
    {
      options.programs.qalculate.definitions = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = { };
        description = "Custom Qalculate definitions to install into XDG data.";
      };

      config = lib.mkIf cfg.enable {
        xdg.dataFile = lib.mapAttrs' (
          name: file: lib.nameValuePair "qalculate/definitions/${name}.xml" { source = file; }
        ) cfg.definitions;
      };
    };
}
