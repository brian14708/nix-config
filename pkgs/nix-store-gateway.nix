{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "nix-store-gateway";
  version = "0-unstable-2025-02-23";
  src = fetchFromGitHub {
    owner = "brian14708";
    repo = "nix-store-gateway";
    rev = "f0e92a764b934c1b9d2de1d866fd986dcd451c92";
    hash = "sha256-FX9i/wwGVDMrFJ95iriWi2mhbOudqLzzDjbrAHSTkOE=";
  };
  cargoHash = "sha256-2P8rmRG70onQmW1insx2WnQ3eq1F+53WcV1dwYZuqnw=";
  useFetchCargoVendor = true;
}
