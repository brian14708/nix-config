{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "nix-store-gateway";
  version = "0-unstable-2025-03-13";
  src = fetchFromGitHub {
    owner = "brian14708";
    repo = "nix-store-gateway";
    rev = "59b034030b5ddb7aa9dca91d418e467bfdfe2d59";
    hash = "sha256-dU32KX2FZ9MMDfdMtgpHjluZ8jvcIbKe2Nsnt3dQRNI=";
  };
  cargoHash = "sha256-2P8rmRG70onQmW1insx2WnQ3eq1F+53WcV1dwYZuqnw=";
  useFetchCargoVendor = true;
}
