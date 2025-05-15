{
  stdenv,
  fetchFromGitHub,
  format ? "raw",
  server ? "114.114.114.114",
  ...
}:
stdenv.mkDerivation {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2025-05-24";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "120d2ffa335f9033f5852b594588288d0346e8dc";
    hash = "sha256-JAia2vsbWCTxp5+L5vxJqdWxEyDCgyp904bQS1wEpfE=";
  };

  buildPhase = ''
    mkdir -p $out
    make SERVER=${server} ${format}
    cp *.conf *.txt $out
  '';
}
