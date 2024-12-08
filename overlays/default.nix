_final: prev: {

  tailscale = prev.tailscale.overrideAttrs (
    _: prev': {
      patches = prev'.patches ++ [ ./tailscale.patch ];

    }
  );
}
