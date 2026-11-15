{
  inputs = {
    # ESP-IDF's binary tools require the nixpkgs version tested upstream.
    nixpkgs.follows = "esp-idf/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    esp-idf = {
      url = "github:mirrexagon/nixpkgs-esp-dev";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          system,
          ...
        }:
        {
          devShells.default = inputs.esp-idf.devShells.${system}.default;
          treefmt.programs = {
            cmake-format.enable = true;
            clang-format.enable = true;
            nixfmt.enable = true;
          };
        };
    };
}
