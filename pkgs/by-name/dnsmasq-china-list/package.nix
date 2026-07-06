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
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "daa54437a98806352000364cca924233bd18d013";
    hash = "sha256-Gj0IHpY3iN7Otl7RlAA2DXG1d99tXHGWpGzBpnzrbqg=";
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
