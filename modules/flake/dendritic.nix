{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.nix-auto-follow
  ];

  flake-file = {
    inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    inputs.flake-compat.url = "github:nixos/flake-compat";
    inputs.crane.url = "github:ipetkov/crane";
    inputs.rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixConfig = {
      extra-substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  flake.templates = import (inputs.self + /templates) { };
}
