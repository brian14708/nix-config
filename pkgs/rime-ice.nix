{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_: {
  pname = "rime-ice";
  version = "2024.11.29-unstable-2024-12-07";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "a0aa1adc556e0cf70195140cc26085687b575f99";
    hash = "sha256-cEQsdPozclEWip4WTVxleFU5x9KMNXq3Y59vLIkT5Zs=";
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
