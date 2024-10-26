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
    force = true;
    text = lib.generators.toINI { } {
      "Groups/0" = {
        Name = "Default";
        "Default Layout" = "us";
        DefaultIM = "rime";
      };
      "Groups/0/Items/0" = {
        Name = "keyboard-us";
        Layout = "";
      };
      "Groups/0/Items/1" = {
        Name = "rime";
        Layout = "";
      };
      "GroupOrder" = {
        "0" = "Default";
      };
    };
  };
  xdg.configFile."fcitx5/config" = {
    text = lib.generators.toINI { } {
      "Hotkey" = {
        EnumerateWithTriggerKeys = "True";
        EnumerateForwardKeys = "";
        EnumerateBackwardKeys = "";
        EnumerateSkipFirst = "False";
      };
      "Hotkey/TriggerKeys" = {
        "0" = "Control+space";
      };
      "Hotkey/AltTriggerKeys" = {
        "0" = "Shift_L";
      };
      "Hotkey/EnumerateForwardKeys" = {
        "0" = "Control+Shift_L";
      };
      "Hotkey/EnumerateBackwardKeys" = {
        "0" = "Control+Shift_R";
      };
      "Hotkey/PrevPage" = {
        "0" = "Up";
      };
      "Hotkey/NextPage" = {
        "0" = "Down";
      };
      "Hotkey/PrevCandidate" = {
        "0" = "Shift+Tab";
      };
      "Hotkey/NextCandidate" = {
        "0" = "Tab";
      };
      "Hotkey/TogglePreedit" = {
        "0" = "Control+Alt+P";
      };
      "Behavior" = {
        "ActiveByDefault" = "False";
        "ShareInputState" = "No";
        "PreeditEnabledByDefault" = "True";
        "ShowInputMethodInformation" = "True";
        "showInputMethodInformationWhenFocusIn" = "False";
        "CompactInputMethodInformation" = "True";
        "ShowFirstInputMethodInformation" = "True";
        "DefaultPageSize" = 5;
        "OverrideXkbOption" = "False";
        "CustomXkbOption" = "";
        "EnabledAddons" = "";
        "PreloadInputMethod" = "True";
      };
    };
  };
  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    text = lib.generators.toYAML { } {
      patch = {
        "menu/page_size" = 5;
      };
    };
  };
}
