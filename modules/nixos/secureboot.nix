{ inputs, ... }:
{
  flake-file.inputs = {
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.secureboot = {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

    boot = {
      initrd.systemd.enable = true;
      loader = {
        systemd-boot = {
          enable = false;
          configurationLimit = 5;
          editor = false;
        };
        efi.canTouchEfiVariables = true;
        timeout = 3;
      };
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
