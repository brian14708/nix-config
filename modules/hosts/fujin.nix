{ config, ... }:
let
  inherit (config.flake.modules) homeManager nixos;
in
{
  flake.modules.homeManager."hosts/fujin" =
    { config, pkgs, ... }:
    {
      imports = with homeManager; [
        workstation-linux
        cli
        catppuccin
        gpg
      ];
      home = {
        packages = with pkgs; [
          chromium
          nodejs
          pnpm
          python3
          uv
        ];
        sessionVariables.PNPM_HOME = "${config.xdg.dataHome}/pnpm";
        sessionPath = [ config.home.sessionVariables.PNPM_HOME ];
      };
    };

  flake.modules.nixos."hosts/fujin" =
    { ... }:
    {
      imports = with nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        docker
        tailscale-subnet
        amd
        stylix
        home-manager
        (config.flake.factory.disko-workstation { })
      ];

      networking.hostName = "fujin";
      system.stateVersion = "24.11";
      stylix.enable = true;

      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      boot.binfmt.preferStaticEmulators = false;

      services = {
        tailscale = {
          useRoutingFeatures = "both";
          extraSetFlags = [
            "--advertise-exit-node"
          ];
        };
        hardware.bolt.enable = true;
      };

      hardware.graphics.enable = true;
    };
}
