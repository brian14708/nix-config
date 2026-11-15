final: prev:
prev.lib.packagesFromDirectoryRecursive {
  inherit (final) callPackage;
  directory = ./by-name;
}
// {
  tailscale = prev.tailscale.overrideAttrs (prevAttrs: {
    patches = (prevAttrs.patches or [ ]) ++ [ ./tailscale.patch ];
    doCheck = false;
  });
}
