{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../wayland ];
  wayland.windowManager.niri = {
    enable = true;
    spawnAtStartup = [ ] ++ (map (cmd: lib.splitString " " cmd) config.my.desktop.startupCommands);
    settings = {
      input = {
        keyboard = {
          xkb = {
            options = "ctrl:nocaps,altwin:swap_alt_win";
          };
          repeat-delay = 250;
        };
        touchpad = {
          tap = [ ];
          natural-scroll = [ ];
          accel-speed = 0.2;
          scroll-factor = 0.2;
        };
        focus-follows-mouse = [ ];
      };
      prefer-no-csd = [ ];
      binds = {
        "Mod+Space".spawn = "fuzzel";
        "Mod+Return".spawn = builtins.toString (
          pkgs.writeScript "foot-launch" ''
            #!${pkgs.dash}/bin/dash
            ${pkgs.foot}/bin/footclient -N || ${pkgs.foot}/bin/foot
          ''
        );
        "Mod+x".spawn = [
          "loginctl"
          "lock-session"
        ];
        "XF86AudioRaiseVolume".spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.1+"
        ];
        "XF86AudioLowerVolume".spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.1-"
        ];
        "XF86AudioMute".spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SINK@"
          "toggle"
        ];
        "XF86AudioMicMute".spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SOURCE@"
          "toggle"
        ];
        "XF86AudioPlay".spawn = [
          "${pkgs.playerctl}/bin/playerctl"
          "play-pause"
        ];
        "XF86AudioStop".spawn = [
          "${pkgs.playerctl}/bin/playerctl"
          "stop"
        ];
        "XF86AudioNext".spawn = [
          "${pkgs.playerctl}/bin/playerctl"
          "next"
        ];
        "XF86AudioPrev".spawn = [
          "${pkgs.playerctl}/bin/playerctl"
          "previous"
        ];
        "XF86MonBrightnessUp".spawn = [
          "${pkgs.brightnessctl}/bin/brightnessctl"
          "set"
          "+10%"
        ];
        "XF86MonBrightnessDown".spawn = [
          "${pkgs.brightnessctl}/bin/brightnessctl"
          "set"
          "10%-"
        ];

        "Mod+Q".close-window = [ ];
        "Mod+H".focus-column-left = [ ];
        "Mod+L".focus-column-right = [ ];
        "Mod+J".focus-window-down = [ ];
        "Mod+K".focus-window-up = [ ];
        "Mod+Shift+H".move-column-left = [ ];
        "Mod+Shift+L".move-column-right = [ ];
        "Mod+Shift+J".move-window-down = [ ];
        "Mod+Shift+K".move-window-up = [ ];
        "Mod+Ctrl+H".focus-monitor-left = [ ];
        "Mod+Ctrl+L".focus-monitor-right = [ ];
        "Mod+Ctrl+J".focus-monitor-down = [ ];
        "Mod+Ctrl+K".focus-monitor-up = [ ];
        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = [ ];
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = [ ];
        "Mod+U".focus-workspace-down = [ ];
        "Mod+I".focus-workspace-up = [ ];
        "Mod+Shift+U".move-column-to-workspace-down = [ ];
        "Mod+Shift+I".move-column-to-workspace-up = [ ];
        "Mod+Ctrl+U".move-workspace-down = [ ];
        "Mod+Ctrl+I".move-workspace-up = [ ];

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;

        "Mod+Shift+1".move-column-to-workspace = 1;
        "Mod+Shift+2".move-column-to-workspace = 2;
        "Mod+Shift+3".move-column-to-workspace = 3;
        "Mod+Shift+4".move-column-to-workspace = 4;
        "Mod+Shift+5".move-column-to-workspace = 5;
        "Mod+Shift+6".move-column-to-workspace = 6;
        "Mod+Shift+7".move-column-to-workspace = 7;
        "Mod+Shift+8".move-column-to-workspace = 8;
        "Mod+Shift+9".move-column-to-workspace = 9;

        "Mod+BracketLeft".consume-or-expel-window-left = [ ];
        "Mod+BracketRight".consume-or-expel-window-right = [ ];
        "Mod+Comma".consume-window-into-column = [ ];
        "Mod+Period".expel-window-from-column = [ ];

        "Mod+R".switch-preset-column-width = [ ];
        "Mod+Shift+R".switch-preset-window-height = [ ];
        "Mod+Ctrl+R".reset-window-height = [ ];
        "Mod+F".maximize-column = [ ];
        "Mod+Shift+F".fullscreen-window = [ ];
        "Mod+Ctrl+F".expand-column-to-available-width = [ ];
        "Mod+C".center-column = [ ];
        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+V".toggle-window-floating = [ ];
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = [ ];

        "Mod+W".toggle-column-tabbed-display = [ ];

        "Print".screenshot = [ ];
        "Ctrl+Print".screenshot-screen = [ ];
        "Alt+Print".screenshot-window = [ ];

        "Mod+Ctrl+Q".quit = [ ];

        # Wheel scroll bindings
        "Mod+WheelScrollUp" = {
          focus-workspace-up = [ ];
          _props.cooldown-ms = 150;
        };
        "Mod+WheelScrollDown" = {
          focus-workspace-down = [ ];
          _props.cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          move-column-to-workspace-up = [ ];
          _props.cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          move-column-to-workspace-down = [ ];
          _props.cooldown-ms = 150;
        };
        "Mod+WheelScrollRight".focus-column-right = [ ];
        "Mod+WheelScrollLeft".focus-column-left = [ ];
        "Mod+Ctrl+WheelScrollRight".move-column-right = [ ];
        "Mod+Ctrl+WheelScrollLeft".move-column-left = [ ];
        "Mod+Shift+WheelScrollDown".focus-column-right = [ ];
        "Mod+Shift+WheelScrollUp".focus-column-left = [ ];
        "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = [ ];
        "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = [ ];
      };
      hotkey-overlay = {
        skip-at-startup = [ ];
      };
      environment = {
        NIXOS_OZONE_WL = "1";
        DISPLAY = ":0";
      };
      screenshot-path = "~/downloads/screenshots/%Y-%m-%d %H-%M-%S.png";
      layout = {
        focus-ring = {
          width = 2;
        };
      };
      cursor = {
        hide-after-inactive-ms = 5000;
        hide-when-typing = [ ];
      };
    };
  };
}
