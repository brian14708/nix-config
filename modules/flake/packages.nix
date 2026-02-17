{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # Expose in-tree packages as flake outputs, e.g. `nix build .#<name>`.
      packages = pkgs.lib.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = inputs.self + /pkgs/by-name;
      };
    };
}
