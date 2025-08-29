{
  stdenv,
  fetchFromGitHub,
  format ? "raw",
  server ? "114.114.114.114",
  ...
}:
stdenv.mkDerivation {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2025-09-15";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "7d80f6f5a4468ee09dd0431cfd17102cadd3a73d";
    hash = "sha256-h554wKJt1Zd5XLHHWhi0SQct+G9Rd1HLJfJzVKKK84o=";
  };

  buildPhase = ''
    mkdir -p $out
    make SERVER=${server} ${format}
    cp *.conf *.txt $out
  '';
}
