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
        nix-update
        home-manager
        sops
        just
        opentofu
      ]
      ++ (if pkgs.stdenv.isDarwin then [ darwin-rebuild ] else [ deploy-rs.deploy-rs ]);
  };
}
