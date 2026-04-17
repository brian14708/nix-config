{ inputs, ... }:
let
  overlay = import (inputs.self + /pkgs);
  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "brian14708.dev:k5awex3ydUORpRlm2AnogCuowVwSxIVi9TxCnY/3ZJQ"
  ];
in
{
  flake = {
    modules = {
      nixos.base = {
        nix.settings = {
          trusted-public-keys = trustedPublicKeys;
          fallback = true;
        };
        nixpkgs = {
          overlays = [ overlay ];
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "electron-38.8.4"
          ];

        };
      };

      # Keep pkgs consistent across NixOS and nix-darwin hosts.
      darwin.base = {
        nix.settings = {
          trusted-public-keys = trustedPublicKeys;
          fallback = true;
        };

        nixpkgs = {
          overlays = [ overlay ];
          config.allowUnfree = true;
        };
      };

      homeManager.base = {
        nix.settings = {
          trusted-public-keys = trustedPublicKeys;
          fallback = true;
        };
      };
    };
  };
}
