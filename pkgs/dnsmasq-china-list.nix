{
  stdenv,
  fetchFromGitHub,
  format ? "raw",
  server ? "114.114.114.114",
  ...
}:
stdenv.mkDerivation {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2025-07-30";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "6b20522303b803441db4985a6e5196213c2c9fe5";
    hash = "sha256-bNwpLw6xl4iFdAkcf9MC36RtFqSU7l7kUlmeqXxgAng=";
  };

  buildPhase = ''
    mkdir -p $out
    make SERVER=${server} ${format}
    cp *.conf *.txt $out
  '';
}
