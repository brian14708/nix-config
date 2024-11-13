{
  pkgs ? import <nixpkgs> { },
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = ''
      accept-flake-config = true
      extra-experimental-features = nix-command flakes
    '';
    SOPS_GPG_EXEC = "/dev/null";
    nativeBuildInputs =
      with pkgs;
      [
        nh
        nix
        home-manager
        git
        sops
        ssh-to-age
        deploy-rs.deploy-rs
        just
        opentofu
      ]
      ++ (if pkgs.stdenv.isDarwin then [ darwin-rebuild ] else [ ]);
  };
}
