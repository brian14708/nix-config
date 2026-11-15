{ inputs, ... }:
let
  overlay = import (inputs.self + /pkgs);
  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "brian14708.dev:k5awex3ydUORpRlm2AnogCuowVwSxIVi9TxCnY/3ZJQ"
  ];
  nixSettings = {
    trusted-public-keys = trustedPublicKeys;
    fallback = true;
  };
  systemBase = {
    nix.settings = nixSettings;
    nixpkgs = {
      overlays = [ overlay ];
      config.allowUnfree = true;
    };
  };
in
{
  flake = {
    modules = {
      # Keep pkgs consistent across NixOS and nix-darwin hosts.
      nixos.base = systemBase;
      darwin.base = systemBase;
      homeManager.base.nix.settings = nixSettings;
    };
  };
}
