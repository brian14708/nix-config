{ ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      trusted-users = [ "@wheel" ];
      allowed-users = [ "@users" ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  services.dbus.implementation = "broker";
  services.speechd.enable = false;
  zramSwap.enable = true;
}
