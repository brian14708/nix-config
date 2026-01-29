{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          stylua.enable = true;
          prettier.enable = true;
          terraform = {
            enable = true;
            package = pkgs.opentofu;
          };
        };
        settings.formatter.stylua.options = [
          "--indent-type=Spaces"
          "--indent-width=2"
        ];
      };
    };
}
