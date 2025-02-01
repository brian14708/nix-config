{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "nix-store-gateway";
  version = "0-unstable-2025-01-30";
  src = fetchFromGitHub {
    owner = "brian14708";
    repo = "nix-store-gateway";
    rev = "e88500f85e65e3fc3fa3bb8c7a090704e159334f";
    hash = "sha256-U48CnhYajltnfPw/WuqH9od8dYn+ZFb+uTd4QRVaXHs=";
  };
  cargoHash = "sha256-n9libXjCgbKVvsJIS6PJTh9Faea0pJLC6Ylkd6/WdaU=";
}
