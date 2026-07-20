{
  lib,
  stdenv,
  fetchFromGitHub,
  format ? "raw",
  server ? "114.114.114.114",
  ...
}:
stdenv.mkDerivation {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2026-07-19";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "6fc5c1cc269ad44f6b645f0552d8167a2d816552";
    hash = "sha256-omSVlOhuwXcPI2/eNcGVBHZfaKbDaQ/jszmcBl9bHiE=";
  };

  buildPhase = ''
    mkdir -p $out
    make SERVER=${server} ${format}
    cp *.conf *.txt $out
  '';

  meta = {
    description = "Chinese-specific configuration to improve your favorite DNS server";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = lib.licenses.wtfpl;
    platforms = lib.platforms.all;
  };
}
