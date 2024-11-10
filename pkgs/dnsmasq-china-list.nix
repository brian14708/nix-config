{
  stdenv,
  fetchFromGitHub,
  format ? "raw",
  server ? "114.114.114.114",
  ...
}:
stdenv.mkDerivation {
  name = "dnsmasq-china-list";
  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "e325882ce9265dce99338c4e416a14618e7dc3ba";
    hash = "sha256-w+xSP/dbZsXjQAClBxXnFo+IFATw5AYtruGgdTADp6c=";
  };
  buildPhase = ''
    mkdir -p $out
    make SERVER=${server} ${format}
    cp *.conf *.txt $out
  '';
}
