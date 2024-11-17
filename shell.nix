{
  pkgs ? import <nixpkgs> { },
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = ''
      accept-flake-config = true
      extra-experimental-features = nix-command flakes
    '';
    nativeBuildInputs =
      with pkgs;
      [
        nh
        nix
        nix-update
        home-manager
        git
        sops
        deploy-rs.deploy-rs
        just
        opentofu
      ]
      ++ (if pkgs.stdenv.isDarwin then [ darwin-rebuild ] else [ ]);
  };
}
