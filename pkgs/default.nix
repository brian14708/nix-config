final: prev:
let
  localPackages = prev.lib.packagesFromDirectoryRecursive {
    inherit (final) callPackage;
    directory = ./by-name;
  };
in
localPackages
// {
  tailscale = prev.tailscale.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./tailscale.patch ];
    doCheck = false;
  });
}
