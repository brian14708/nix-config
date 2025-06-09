{
  lib,
  pkgs,
  ...
}:
{
  xdg.dataFile = {
    "fcitx5/rime" = {
      source = "${pkgs.rime-ice}/share/rime-data";
      recursive = true;
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
      ];
    };
  };
  systemd.user.services.fcitx5-daemon.Unit = {
    After = [
      "graphical-session-pre.target"
    ];
    ConditionEnvironment = "WAYLAND_DISPLAY";
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
  home.file.".config/fcitx5/config" = {
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
