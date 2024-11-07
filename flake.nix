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
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vsc = {
      url = "github:catppuccin/vscode";
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
            lab01 = nixpkgs.lib.nixosSystem {
              pkgs = pkgsFor "x86_64-linux";
              system = "x86_64-linux";
              modules = [
                ./hosts/lab01
              ];
              specialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = false;
                };
              };
            };
            vmtest = nixpkgs.lib.nixosSystem {
              pkgs = pkgsFor "x86_64-linux";
              system = "x86_64-linux";
              modules = [
                ./hosts/vmtest
              ];
              specialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = false;
                };
              };
            };
          };

          homeConfigurations = {
            "brian@macbookpro" = home-manager.lib.homeManagerConfiguration {
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
            "brian" = home-manager.lib.homeManagerConfiguration {
              pkgs = pkgsFor "x86_64-linux";
              modules = [
                ./home/brian/generic.nix
              ];
              extraSpecialArgs = {
                inherit inputs outputs;
                machine = {
                  trusted = false;
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
              terraform = {
                enable = true;
                package = pkgs.opentofu;
              };
            };
            settings.formatter.stylua.options = [
              "--indent-type=Spaces"
              "--indent-width=2"
            ];
          };
          devShells = import ./shell.nix pkgs;
        };
    };

  nixConfig = {
    extra-substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://brian14708.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "brian14708.cachix.org-1:ZTO1dfqDryBeRpLJwn/czQj0HFC0TPuV2aK+81o2mSs="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
