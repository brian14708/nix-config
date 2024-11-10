{ pkgs, ... }:
{
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
}
