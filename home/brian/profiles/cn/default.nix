{
  config,
  lib,
  ...
}:
let
  home = config.home.homeDirectory;
in
{
  home.file = {
    ".cargo/config.toml" = {
      text = lib.mkBefore ''
        [source.crates-io]
        replace-with = 'rsproxy-sparse'
        [source.rsproxy]
        registry = "https://rsproxy.cn/crates.io-index"
        [source.rsproxy-sparse]
        registry = "sparse+https://rsproxy.cn/index/"
        [registries.rsproxy]
        index = "https://rsproxy.cn/crates.io-index"
        [net]
        git-fetch-with-cli = true
      '';
    };
  };
  xdg.configFile."go/env" = {
    text = ''
      GOPATH=${home}/.local/go
      GOPROXY=https://goproxy.cn,direct
    '';
  };
  nix = {
    settings = {
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };
}
