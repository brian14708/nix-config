{ lib, ... }:
let
  # Homebrew Mirror
  homebrew_mirror_env = {
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
in
{
  flake.modules = {
    darwin.locale-cn = {
      # Set variables for you to manually install homebrew packages.
      environment.variables = homebrew_mirror_env;

      # Set environment variables for nix-darwin before run `brew bundle`.
      system.activationScripts.homebrew.text =
        let
          env_script = lib.attrsets.foldlAttrs (
            acc: name: value:
            acc + "\nexport ${name}=${value}"
          ) "" homebrew_mirror_env;
        in
        lib.mkBefore ''
          echo >&2 '${env_script}'
          ${env_script}
        '';
    };

    nixos.locale-cn = {
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "Asia/Hong_Kong";
      nix.settings = {
        substituters = [
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
          "https://cache.nixos.org?priority=100"
        ];
      };
    };

    homeManager.locale-cn =
      { config, ... }:
      let
        home = config.home.homeDirectory;
      in
      {
        home.file = {
          ".cargo/config.toml".text = lib.mkBefore ''
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

        xdg.configFile."go/env".text = ''
          GOPATH=${home}/.local/go
          GOPROXY=https://goproxy.cn,direct
        '';

        nix.settings = {
          substituters = [
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
            "s3://nix-cache-miecho3l?endpoint=oss-cn-beijing.aliyuncs.com&addressing-style=virtual&profile=nix-cache-miecho3l&priority=20"
            "https://cache.nixos.org?priority=100"
          ];
        };
      };
  };
}
