final: prev:
prev.lib.mergeAttrsList [
  (prev.lib.packagesFromDirectoryRecursive {
    inherit (final) callPackage;
    directory = ./by-name;
  })
  {
    tailscale = prev.tailscale.overrideAttrs (
      finalAttrs: prevAttrs: {
        patches = (prevAttrs.patches or [ ]) ++ [ ./tailscale.patch ];
        doCheck = false;
      }
    );
  }
]
