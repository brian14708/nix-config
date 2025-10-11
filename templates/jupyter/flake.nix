{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          devShells.default = pkgs.mkShell {
            venvDir = ".venv";
            packages =
              with pkgs;
              [
                uv
                python3
              ]
              ++ (with python3Packages; [
                venvShellHook
                pip
                jupyter
                numpy
              ]);
            postShellHook = ''
              PYTHONPATH=$PWD/$venvDir/${pkgs.python3.sitePackages}:$PYTHONPATH
            '';
          };
        };
    };
}
