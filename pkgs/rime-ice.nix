{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_: {
  pname = "rime-ice";
  version = "2025.04.06-unstable-2025-08-16";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "39b04584c216fec7cdc30270fc9b6f054423e202";
    hash = "sha256-AP2T4G/KDVOLzzRXHrO2c33bV/HxSOhu8QCeiUP/IzI=";
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
