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
        nixVersions.latest
        nix-update
        home-manager
        git
        sops
        deploy-rs.deploy-rs
        just
        opentofu

        nil
        nixfmt-rfc-style
        lua-language-server
      ]
      ++ (if pkgs.stdenv.isDarwin then [ darwin-rebuild ] else [ ]);
  };
}
