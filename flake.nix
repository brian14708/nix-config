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
      url = "github:Mic92/sops-nix/59d6988329626132eaf107761643f55eb979eef1";
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
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      pkgsFor = nixpkgs.lib.genAttrs systems (
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
      forAllSystems = nixpkgs.lib.genAttrs systems;
      treefmtEval = forAllSystems (
        system: inputs.treefmt-nix.lib.evalModule pkgsFor.${system} ./treefmt.nix
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
            nixpkgs.lib.nixosSystem {
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
        {
          aether = nixosConfig {
            modules = [ ./hosts/aether ];
          };
          fujin = nixosConfig {
            modules = [ ./hosts/fujin ];
          };
          fuxi = nixosConfig {
            modules = [ ./hosts/fuxi ];
          };
          lab01 = nixosConfig {
            modules = [ ./hosts/lab01 ];
          };
          watchtower = nixosConfig {
            modules = [ ./hosts/watchtower ];
          };
          aliyun-base = nixosConfig {
            modules = [ ./hosts/profiles/aliyun ];
          };
        };

      deploy.nodes =
        let
          deployConfig =
            {
              hostname,
              sshUser ? "ops",
              system ? "x86_64-linux",
              home ? { },
            }:
            {
              inherit sshUser hostname;
              profilesOrder = [ "system" ] ++ builtins.attrNames home;
              profiles =
                let
                  activate = deploy-rs.lib.${system}.activate;
                in
                {
                  system = {
                    user = "root";
                    path = activate.nixos self.nixosConfigurations.${hostname};
                  };
                }
                // (nixpkgs.lib.mapAttrs (
                  name:
                  { }:
                  {
                    sshUser = name;
                    user = name;
                    path = activate.home-manager self.homeConfigurations."${name}@${hostname}";
                  }
                ) home);
            };
        in
        {
          watchtower = deployConfig {
            hostname = "watchtower";
          };
          lab01 = deployConfig {
            hostname = "lab01";
          };
          fujin = deployConfig {
            hostname = "fujin";
            home = {
              brian = { };
            };
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
        {
          "brian@macbookpro" = hmConfig {
            system = "aarch64-darwin";
            modules = [ ./home/brian/mbp ];
          };
          "brian@shiva" = hmConfig {
            modules = [ ./home/brian/shiva.nix ];
          };
          "brian@fuxi" = hmConfig {
            modules = [ ./home/brian/fuxi.nix ];
          };
          "brian@aether" = hmConfig {
            modules = [ ./home/brian/aether ];
          };
          "brian@fujin" = hmConfig {
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
        {
          "macbookpro" = darwinConfig {
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
