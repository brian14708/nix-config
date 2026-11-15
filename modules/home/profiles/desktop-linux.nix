{ config, ... }:
{
  flake.modules.homeManager.desktop-linux = {
    imports = with config.flake.modules.homeManager; [
      workstation-linux
      niri
      fcitx5
      media
      chromium
      cli
      catppuccin
    ];
  };
}
