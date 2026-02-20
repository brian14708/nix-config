{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        NIX_CONFIG = ''
          accept-flake-config = true
          extra-experimental-features = nix-command flakes
        '';
        nativeBuildInputs = with pkgs; [
          nh
          sops
          just
          opentofu
          colmena
        ];
      };
    };
}
