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
  version = "0-unstable-2026-07-09";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "5f56753baa41dcf3ae367d44d552cdbf14f10fc1";
    hash = "sha256-XlhwDCGibcf9sLjQlbG6hvPp0mFEmw1aFxJCYrbdTaw=";
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
