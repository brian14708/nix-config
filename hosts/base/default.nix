{ ... }:
{
  nix = {
    settings = {
      use-xdg-base-directories = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://brian14708.cachix.org"
        "https://cache.nixos.org"
      ];
      extra-trusted-public-keys = [
        "brian14708.cachix.org-1:ZTO1dfqDryBeRpLJwn/czQj0HFC0TPuV2aK+81o2mSs="
      ];
      trusted-users = [ "@wheel" ];
      allowed-users = [ "@users" ];
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  services.dbus.implementation = "broker";
  services.speechd.enable = false;
  zramSwap.enable = true;
}
