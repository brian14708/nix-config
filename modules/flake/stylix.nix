{ inputs, lib, ... }:
let
  defaultScheme = lib.mkDefault "${inputs.base16-schemes}/base16/default-dark.yaml";
in
{
  flake-file.inputs = {
    # Match the existing palettes and let Stylix read them during evaluation.
    base16-schemes = {
      url = "github:tinted-theming/schemes/43dd14f6466a782bd57419fdfb5f398c74d6ac53";
      flake = false;
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  flake.modules = {
    nixos.stylix = {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix.enableReleaseChecks = lib.mkDefault false;
      stylix.base16Scheme = defaultScheme;
      stylix.targets.kmscon.enable = lib.mkDefault false;
      stylix.targets.regreet.enable = lib.mkDefault false;
    };

    homeManager.stylix = {
      imports = [ inputs.stylix.homeModules.stylix ];
      stylix.enableReleaseChecks = lib.mkDefault false;
    };

    darwin.stylix = {
      imports = [ inputs.stylix.darwinModules.stylix ];
      stylix.enable = true;
      stylix.base16Scheme = defaultScheme;
    };
  };
}
