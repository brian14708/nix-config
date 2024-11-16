{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    devenv
    ripgrep
  ];
}
