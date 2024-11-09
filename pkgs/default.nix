{
  pkgs ? import <nixpkgs> { },
}:
{
  rime-ice = pkgs.callPackage ./rime-ice.nix { };
}
