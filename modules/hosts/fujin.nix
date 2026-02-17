{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/fujin" =
    { config, pkgs, ... }:
    {
      imports = with hm; [
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
      services.den = {
        enable = true;
        config = {
          port = 4444;
          rust_log = "info";
          rp_id = "014708.xyz";
          rp_origin = "https://lab.014708.xyz";
          allowed_hosts = [
            "http://100.125.74.26:4444"
            "http://fujin:4444"
          ];
        };
      };
    };

  flake.modules.nixos."hosts/fujin" =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
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

      virtualisation.podman.enable = true;
      hardware.graphics.enable = true;
    };
}
