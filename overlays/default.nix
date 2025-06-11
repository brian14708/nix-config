_final: prev: {
  tailscale = prev.tailscale.overrideAttrs (_: {
    patches = [ ./tailscale.patch ];
    doCheck = false;
  });
}
