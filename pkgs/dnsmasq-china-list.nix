{
  stdenv,
  fetchFromGitHub,
  format ? "raw",
  server ? "114.114.114.114",
  ...
}:
stdenv.mkDerivation {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2024-11-25";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "eb5668fca9feb0148f4df4a43f8e9370c1252200";
    hash = "sha256-L33vr1+VRWNm0lWLNpIBET+8OCXWFyeEf4xg47qdk9g=";
  };

  buildPhase = ''
    mkdir -p $out
    make SERVER=${server} ${format}
    cp *.conf *.txt $out
  '';
}
