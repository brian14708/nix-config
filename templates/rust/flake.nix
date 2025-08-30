{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      crane,
      nixpkgs,
      rust-overlay,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          self',
          system,
          pkgs,
          ...
        }:
        let
          rustToolchain = (p: p.rust-bin.stable.latest.default);
          craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
          pname = "hello";
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
          devShells.default =
            (craneLib.devShell.override {
              mkShell = pkgs.mkShell.override {
                stdenv =
                  if pkgs.stdenv.hostPlatform.isDarwin then
                    pkgs.clangStdenv
                  else
                    pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;
              };
            })
              {
              };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              rustfmt = {
                enable = true;
                package = rustToolchain pkgs;
              };
            };
          };

          apps = {
            default = {
              type = "app";
              program = "${self'.packages.default}/bin/${pname}";
              meta.description = "A simple rust program";
            };
          };

          packages = {
            default =
              let
                commonArgs = {
                  inherit pname;
                  src = craneLib.cleanCargoSource ./.;
                  strictDeps = true;
                  stdenv = p: p.clangStdenv;
                };
              in
              craneLib.buildPackage (
                commonArgs
                // {
                  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
                }
              );
            oci = pkgs.dockerTools.buildImage {
              name = pname;
              tag = "latest";
              copyToRoot = [ self'.packages.default ];
              config = {
                Cmd = [ "/bin/${pname}" ];
              };
            };
          };
          checks = {
          }
          // (pkgs.lib.mapAttrs' (n: pkgs.lib.nameValuePair "package-${n}") self'.packages);
        };
      flake = {
      };
    };
}
