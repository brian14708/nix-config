{ lib, ... }:
{
  flake.modules.darwin.base = {
    nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  };
}
