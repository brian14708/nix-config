{
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Asia/Hong_Kong";
  nix = {
    settings = {
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };
}
