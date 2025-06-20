{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-compat.follows = "flake-compat";
      };
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      deploy-rs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;
      pkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            deploy-rs.overlays.default
            inputs.nix-darwin.overlays.default
            (import ./overlays)
            (final: _prev: import ./pkgs { pkgs = final; })
          ];
          config.allowUnfree = true;
        }
      );
      treefmtEval = forAllSystems (
        system: inputs.treefmt-nix.lib.evalModule pkgsFor.${system} ./treefmt.nix
      );
      mapConfig =
        func: configs:
        lib.mapAttrs (_name: value: func (builtins.removeAttrs value [ "enable" ])) (
          lib.filterAttrs (
            _name:
            {
              enable ? true,
              ...
            }:
            enable
          ) configs
        );
    in
    {
      nixosConfigurations =
        let
          nixosConfig =
            {
              system ? "x86_64-linux",
              modules,
            }:
            lib.nixosSystem {
              inherit system;
              modules = [
                inputs.sops-nix.nixosModules.sops
                inputs.disko.nixosModules.disko
                inputs.home-manager.nixosModules.home-manager
                inputs.stylix.nixosModules.stylix
                ./modules/nixos
              ] ++ modules;
              pkgs = pkgsFor.${system};
              specialArgs = {
                inherit (self) inputs outputs;
              };
            };
        in
        mapConfig nixosConfig {
          aether = {
            modules = [ ./hosts/workstation/aether ];
          };
          fujin = {
            modules = [ ./hosts/workstation/fujin ];
          };
          fuxi = {
            modules = [ ./hosts/workstation/fuxi ];
          };
          shiva = {
            modules = [ ./hosts/workstation/shiva ];
          };
          styx = {
            modules = [ ./hosts/workstation/styx ];
          };
          macbookpro-vm = {
            modules = [ ./hosts/workstation/mbp/vm ];
            system = "aarch64-linux";
          };
          lab01 = {
            modules = [ ./hosts/lab/lab01 ];
          };
          watchtower = {
            modules = [ ./hosts/lab/watchtower ];
          };
          lab-aliyun = {
            modules = [ ./hosts/lab/base-aliyun.nix ];
          };
        };

      deploy.nodes =
        let
          deployConfig =
            {
              hostname,
              sshUser ? "ops",
              system ? "x86_64-linux",
            }:
            {
              inherit sshUser hostname;
              profiles =
                let
                  inherit (deploy-rs.lib.${system}) activate;
                in
                {
                  system = {
                    user = "root";
                    path = activate.nixos self.nixosConfigurations.${hostname};
                  };
                };
            };
        in
        mapConfig deployConfig {
          "watchtower" = {
            hostname = "watchtower";
          };
          "lab01" = {
            enable = true;
            hostname = "lab01";
          };
        };

      homeConfigurations =
        let
          hmConfig =
            {
              system ? "x86_64-linux",
              modules,
            }:
            home-manager.lib.homeManagerConfiguration {
              modules = [
                inputs.stylix.homeModules.stylix
                ./modules/home-manager
              ] ++ modules;
              pkgs = pkgsFor.${system};
              extraSpecialArgs = {
                inherit (self) inputs outputs;
                hmStandalone = true;
              };
            };
        in
        mapConfig hmConfig {
        };

      darwinConfigurations =
        let
          darwinConfig =
            {
              system ? "aarch64-darwin",
              modules,
            }:
            nix-darwin.lib.darwinSystem {
              inherit system;
              modules = [
                inputs.stylix.darwinModules.stylix
                ./modules/nix-darwin
              ] ++ modules;
              pkgs = pkgsFor.${system};
              specialArgs = {
                inherit (self) inputs outputs;
              };
            };

        in
        mapConfig darwinConfig {
          "macbookpro" = {
            modules = [ ./hosts/workstation/mbp ];
          };
        };

      templates = import ./templates { };

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (
        system:
        {
          formatting = treefmtEval.${system}.config.build.check self;
        }
        // deploy-rs.lib.${system}.deployChecks self.deploy
      );
      devShells = forAllSystems (
        system:
        import ./shell.nix {
          pkgs = pkgsFor.${system};
        }
      );
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
}
