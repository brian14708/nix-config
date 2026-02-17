{ inputs, lib, ... }:
{
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
    };
  };

  flake.modules = {
    nixos.stylix =
      { pkgs, ... }:
      {
        imports = [ inputs.stylix.nixosModules.stylix ];
        stylix.base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
      };

    homeManager.stylix = {
      imports = [ inputs.stylix.homeModules.stylix ];
    };

    darwin.stylix =
      { pkgs, ... }:
      {
        imports = [ inputs.stylix.darwinModules.stylix ];
        stylix.enable = true;
        stylix.base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
      };
  };
}
