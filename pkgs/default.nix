{
  pkgs ? import <nixpkgs> { },
}:
{
  rime-ice = pkgs.callPackage ./rime-ice.nix { };
  dnsmasq-china-list = pkgs.callPackage ./dnsmasq-china-list.nix { };
  nix-store-gateway = pkgs.callPackage ./nix-store-gateway.nix { };
}
