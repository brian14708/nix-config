{ inputs, ... }:
let
  overlay = import (inputs.self + /pkgs);
in
{
  flake = {
    overlays.default = overlay;

    modules = {
      nixos.base.nixpkgs = {
        overlays = [ overlay ];
        config.allowUnfree = true;
      };

      # Keep pkgs consistent across NixOS and nix-darwin hosts.
      darwin.base.nixpkgs = {
        overlays = [ overlay ];
        config.allowUnfree = true;
      };
    };
  };
}
