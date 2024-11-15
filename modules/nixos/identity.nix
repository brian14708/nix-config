{ lib, ... }:
with lib;
{
  options.identity = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          name = mkOption {
            type = types.str;
          };
          email = mkOption {
            type = types.listOf types.str;
          };
          ssh = mkOption {
            type = types.listOf types.str;
          };
          pgp = mkOption {
            type = types.listOf types.str;
          };
        };
      }
    );
    default = { };
  };
}
