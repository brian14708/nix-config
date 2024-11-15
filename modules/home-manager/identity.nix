{ lib, ... }:
with lib;
{
  options = {
    identity.name = mkOption {
      type = types.str;
    };
    identity.email = mkOption {
      type = types.listOf types.str;
    };
    identity.ssh = mkOption {
      type = types.listOf types.str;
    };
    identity.pgp = mkOption {
      type = types.listOf types.str;
    };
  };

}
