{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_: {
  pname = "rime-ice";
  version = "2024.09.25";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "ea74e40bec2bd6580fa8d807075cd107739ba6cd";
    hash = "sha256-R2K2LNycXqsUxXvMMq5fcQJUhDnhQMcTlvryMLeiKH0=";
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
    description = "雾凇拼音，功能齐全，词库体验良好，长期更新修订";
    homepage = "https://github.com/iDvel/rime-ice";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ chen ];
  };
})
