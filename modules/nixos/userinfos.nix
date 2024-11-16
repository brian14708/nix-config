{ lib, ... }:
with lib;
{
  options.userinfos = mkOption {
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
            type = types.listOf (
              types.submodule {
                options = {
                  id = mkOption { type = types.str; };
                  key = mkOption { type = types.path; };
                };
              }
            );
          };
        };
      }
    );
    default = { };
  };
}
