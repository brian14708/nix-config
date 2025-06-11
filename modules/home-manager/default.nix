{ pkgs, lib, ... }:
{
  imports = [
    ./desktop.nix
    ./niri.nix
    ./userinfo.nix
    ./nix-store-gateway.nix
    ./qalculate.nix
  ];
  stylix.base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
}
