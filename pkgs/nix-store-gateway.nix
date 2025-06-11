{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "nix-store-gateway";
  version = "0-unstable-2025-07-29";
  src = fetchFromGitHub {
    owner = "brian14708";
    repo = "nix-store-gateway";
    rev = "00ac8733b0194704da5507b40cf7a330b85f1c34";
    hash = "sha256-etaeyeHAkF1dxs8saqgTRDy4XWkQigan5fHkxWfpbhU=";
  };
  cargoHash = "sha256-Pfo+n3UY9RiEjgFsqx6QkiAopNTv1xMql23OZJUCv+E=";
}
