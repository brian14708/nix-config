{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_: {
  pname = "rime-ice";
  version = "2024.09.25-unstable-2024-11-26";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "a37e5d08a1a1da94d5b86cbf2d8a1342895ee625";
    hash = "sha256-uJijNurOdu7OzeGgIPOpXx1H+5bem1dqYGRkId/NdPA=";
  };

  installPhase = ''
    mkdir -p "$out/share/rime-data"
    cp -r cn_dicts "$out/share/rime-data/cn_dicts"
    cp -r en_dicts "$out/share/rime-data/en_dicts"
    cp -r opencc   "$out/share/rime-data/opencc"
    cp -r lua      "$out/share/rime-data/lua"

    install -Dm644 *.{schema,dict}.yaml -t "$out/share/rime-data/"
    install -Dm644 *.lua                -t "$out/share/rime-data/"
    install -Dm644 custom_phrase.txt    -t "$out/share/rime-data/"
    install -Dm644 symbols*.yaml        -t "$out/share/rime-data/"
    install -Dm644 default.yaml         -t "$out/share/rime-data/"
  '';

  meta = {
    description = "Rime 配置：雾凇拼音 | 长期维护的简体词库";
    homepage = "https://github.com/iDvel/rime-ice";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
})
