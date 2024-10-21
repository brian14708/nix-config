{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];
      flake =
        let
          inherit (self) outputs;
          pkgsFor =
            system:
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
        in
        {
          nixosConfigurations = {
            aether = nixpkgs.lib.nixosSystem {
              pkgs = pkgsFor "x86_64-linux";
              system = "x86_64-linux";
              modules = [
                ./hosts/aether
              ];
              specialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = true;
                };
              };
            };
          };

          homeConfigurations = {
            "brian@MacBookPro" = home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor "aarch64-darwin";
              modules = [
                ./home/brian/mbp.nix
              ];
              extraSpecialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = true;
                };
              };
            };
            "brian@shiva" = home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor "x86_64-linux";
              modules = [
                ./home/brian/shiva.nix
              ];
              extraSpecialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = true;
                };
              };
            };
            "brian@fuxi" = home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor "x86_64-linux";
              modules = [
                ./home/brian/fuxi.nix
              ];
              extraSpecialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = true;
                };
              };
            };
            "brian@aether" = home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor "x86_64-linux";
              modules = [
                ./home/brian/aether.nix
              ];
              extraSpecialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = true;
                };
              };
            };
          };
        };
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        { config, pkgs, ... }:
        {
          treefmt.config = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              stylua.enable = true;
              prettier.enable = true;
            };
            settings.formatter.stylua.options = [
              "--indent-type=Spaces"
              "--indent-width=2"
            ];
          };
          devShells = import ./shell.nix pkgs;
        };
    };
}
