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
      ];
      home = {
        packages = with pkgs; [
          nodejs
          pnpm
          python3
          uv
        ];
        sessionVariables.PNPM_HOME = "${config.xdg.dataHome}/pnpm";
        sessionPath = [ config.home.sessionVariables.PNPM_HOME ];
      };
      programs.gpg = {
        enable = true;
      };
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
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
      boot.binfmt.preferStaticEmulators = true;

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
