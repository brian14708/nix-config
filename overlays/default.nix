_final: prev: {

  tailscale =
    prev.tailscale.overrideAttrs (
      _: prev': {
        patches = prev'.patches ++ [ ./tailscale.patch ];

      }
    )
    // {
      derper = prev.tailscale.derper.overrideAttrs (
        _: prev': {
          patches = prev'.patches ++ [ ./derper.patch ];
        }
      );
    };
}
