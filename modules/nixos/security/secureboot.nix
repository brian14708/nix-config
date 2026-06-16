{ inputs, ... }:
{
  flake-file.inputs = {
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
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
