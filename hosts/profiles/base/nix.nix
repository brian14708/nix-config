{ config, lib, ... }:
{
  nix =
    {
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
    }
    // lib.optionalAttrs (config.sops.secrets ? nix-access-tokens) {
      extraOptions = "!include ${config.sops.secrets.nix-access-tokens.path}";
    };
}
