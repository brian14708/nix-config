{ lib, ... }:
with lib;
{
  options.userinfo = {
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
