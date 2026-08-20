{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "nightly-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "59fcb4a6bfa71e6ba4fc83af07ee55f0c5b76081";
    hash = "sha256-7GkVzzQaZBhglp3rPqYtyElWwZKABKnfmG/79NEWMK0=";
  };

  installPhase = ''
    mkdir -p "$out/share/rime-data"
    cp -r cn_dicts "$out/share/rime-data/cn_dicts"
    cp -r en_dicts "$out/share/rime-data/en_dicts"
    cp -r opencc   "$out/share/rime-data/opencc"
    cp -r lua      "$out/share/rime-data/lua"

    install -Dm644 *.yaml -t "$out/share/rime-data/"
    install -Dm644 custom_phrase.txt    -t "$out/share/rime-data/"
  '';

  meta = {
    description = "Rime 配置：雾凇拼音 | 长期维护的简体词库";
    homepage = "https://github.com/iDvel/rime-ice";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
}
