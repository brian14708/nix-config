{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
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
        "aarch64-darwin"
      ];
      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            deploy-rs.overlay
            inputs.nix-darwin.overlays.default
            (import ./overlays)
            (final: _prev: import ./pkgs { pkgs = final; })
          ];
          config.allowUnfree = true;
        }
      );
      forAllSystems = lib.genAttrs systems;
      treefmtEval = forAllSystems (
        system: inputs.treefmt-nix.lib.evalModule pkgsFor.${system} ./treefmt.nix
      );
      mapConfig =
        func: configs:
        lib.mapAttrs (_name: value: func value) (
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
              pkgs = pkgsFor.${system};
              modules = [
                ./modules/nixos
              ] ++ modules;
              specialArgs = {
                inherit (self) inputs outputs;
              };
            };
        in
        mapConfig nixosConfig {
          aether = {
            modules = [ ./hosts/aether ];
          };
          fujin = {
            modules = [ ./hosts/fujin ];
          };
          fuxi = {
            modules = [ ./hosts/fuxi ];
          };
          lab01 = {
            modules = [ ./hosts/lab01 ];
          };
          watchtower = {
            modules = [ ./hosts/watchtower ];
          };
          aliyun-base = {
            modules = [ ./hosts/profiles/aliyun.nix ];
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
                  activate = deploy-rs.lib.${system}.activate;
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
            enable = false;
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
              modules = [ ./modules/home-manager ] ++ modules;
              pkgs = pkgsFor.${system};
              extraSpecialArgs = {
                inherit (self) inputs outputs;
              };
            };
        in
        mapConfig hmConfig {
          "brian@macbookpro" = {
            system = "aarch64-darwin";
            modules = [ ./home/brian/mbp ];
          };
          "brian@shiva" = {
            modules = [ ./home/brian/shiva.nix ];
          };
          "brian@fuxi" = {
            modules = [ ./home/brian/fuxi ];
          };
          "brian@aether" = {
            modules = [ ./home/brian/aether ];
          };
          "brian@fujin" = {
            modules = [ ./home/brian/fujin ];
          };
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
              pkgs = pkgsFor.${system};
              modules = [ ./modules/nix-darwin ] ++ modules;
              specialArgs = {
                inherit (self) inputs outputs;
              };
            };

        in
        mapConfig darwinConfig {
          "macbookpro" = {
            modules = [ ./hosts/macbookpro ];
          };
        };

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
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
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
