{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "nix-store-gateway";
  version = "0-unstable-2025-02-05";
  src = fetchFromGitHub {
    owner = "brian14708";
    repo = "nix-store-gateway";
    rev = "0f867b7133632e653e033ba1401954162aca8fc1";
    hash = "sha256-O9pX0jQ62N5xUoigUTy4/KmtdW78hRtb8QsypxgFnGQ=";
  };
  cargoHash = "sha256-AhU/ox7J8ITy/TKE2dFRis+7NP1HYO7OCsxBEiw/GiQ=";
}
