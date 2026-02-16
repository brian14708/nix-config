{ inputs, ... }:
{
  flake-file.inputs.den = {
    url = "github:brian14708/den";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.base =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.services.den;
      defaultPackage = inputs.den.packages.${pkgs.stdenv.hostPlatform.system}.default;
      tomlFormat = pkgs.formats.toml { };
    in
    {
      options.services.den = {
        enable = lib.mkEnableOption "den service";
        package = lib.mkOption {
          type = lib.types.package;
          default = defaultPackage;
          defaultText = lib.literalExpression "inputs.den.packages.${pkgs.stdenv.hostPlatform.system}.default";
          description = "The den package to run.";
        };
        config = lib.mkOption {
          type = lib.types.nullOr tomlFormat.type;
          default = null;
          example = {
            port = 3000;
            rust_log = "info";
          };
          description = "Configuration for ~/.config/den/config.toml.";
        };
      };

      config = lib.mkIf cfg.enable {
        xdg.configFile = lib.optionalAttrs (cfg.config != null) {
          "den/config.toml".source = tomlFormat.generate "den-config.toml" cfg.config;
        };

        systemd.user.services.den = {
          Unit = {
            Description = "den";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            ExecStart = "${cfg.package}/bin/den";
            Restart = "on-failure";
            RestartSec = "5s";
            Environment = [
              "XDG_CONFIG_HOME=%h/.config"
              "XDG_DATA_HOME=%h/.local/share"
            ];
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
