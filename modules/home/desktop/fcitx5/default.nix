{
  config,
  lib,
  pkgs,
  ...
}:
let
  rime-ice-pkg = pkgs.callPackage ./rime-ice.nix { };
in
{
  xdg.dataFile = {
    "fcitx5/rime" = {
      source = "${rime-ice-pkg}/share/rime-data";
      recursive = true;
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      catppuccin.enable = false;
      addons = with pkgs; [
        fcitx5-rime
        catppuccin-fcitx5
      ];
    };
  };

  xdg.configFile."fcitx5/conf/classicui.conf" = {
    text = lib.generators.toINIWithGlobalSection { } {
      globalSection.Theme = "catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}";
    };
  };
  xdg.configFile."fcitx5/profile" = {
    text = lib.generators.toINI { } {
      "Groups/0" = {
        Name = "Default";
        "Default Layout" = "us";
        DefaultIM = "rime";
      };
      "Groups/0/Items/0" = {
        Name = "keyboard-us";
      };
      "Groups/0/Items/1" = {
        Name = "rime";
      };
      "GroupOrder" = {
        "0" = "Default";
      };
    };
  };
}
