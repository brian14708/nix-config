{ lib, config, ... }:
{
  flake.modules.darwin.base = {
    imports = [ config.flake.modules.generic.owner ];
    nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  };
}
