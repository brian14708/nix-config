{ ... }:
{
  imports = [
    ./nix.nix
  ];
  userinfos = {
    brian = (import ../../../home/brian/profiles/base/userinfo.nix).userinfo;
  };
}
