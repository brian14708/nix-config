{
  stdenv,
  fetchFromGitHub,
  format ? "raw",
  server ? "114.114.114.114",
  ...
}:
stdenv.mkDerivation {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2025-03-29";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "275507778c8c794d178c5287bb6bbfdd4572fbf3";
    hash = "sha256-o143uZpETTk9nS6WU8jtq3pi7rJJRoVLuOvAmw0sxYY=";
  };

  buildPhase = ''
    mkdir -p $out
    make SERVER=${server} ${format}
    cp *.conf *.txt $out
  '';
}
