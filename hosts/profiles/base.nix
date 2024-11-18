{ pkgs, ... }:
{
  userinfos = {
    brian = (import ../../home/brian/profiles/base/userinfo.nix).userinfo;
  };
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
