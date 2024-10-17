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
      flake =
        let
          inherit (self) outputs;
          pkgsFor =
            system:
            import nixpkgs {
              inherit system;
            };
        in
        {
          nixosConfigurations = {
            aether = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                ./hosts/aether
              ];
              specialArgs = {
                inherit inputs outputs;
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
          formatter = pkgs.nixfmt-rfc-style;
          devShells = import ./shell.nix pkgs;
        };
    };
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org/"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
