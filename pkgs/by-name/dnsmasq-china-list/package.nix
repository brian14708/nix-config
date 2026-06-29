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
  version = "0-unstable-2026-06-27";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "995dcdc557ca77b59cd54879b2e231fdcdf3f07f";
    hash = "sha256-JreNJXR+IaxKxjsSTAxMXXkDIo63rUyvppJ7viDE3ac=";
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
