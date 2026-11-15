toplevel@{ config, lib, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      checks = {
        # Flake checks do not validate the custom darwinConfigurations output.
        # Force every host's build derivation, without building foreign systems.
        configurations = pkgs.writeText "configuration-evaluation.json" (
          builtins.toJSON {
            nixos = lib.mapAttrs (
              _: host: builtins.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath
            ) toplevel.config.flake.nixosConfigurations;
            darwin = lib.mapAttrs (
              _: host: builtins.unsafeDiscardStringContext host.system.drvPath
            ) toplevel.config.flake.darwinConfigurations;
          }
        );

        nvim = config.packages.nvim;
      };
    };
}
