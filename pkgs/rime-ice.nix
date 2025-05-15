{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_: {
  pname = "rime-ice";
  version = "2025.04.06-unstable-2025-05-19";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "7fab37280f1a90055007f561518c7daf59da9a09";
    hash = "sha256-vWjAJ7UEnuGpYVfqwLt0Cq1jzz+S+DjivQpR9QKyad8=";
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
})
