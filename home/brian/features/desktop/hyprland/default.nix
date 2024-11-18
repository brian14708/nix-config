{
  pkgs,
  ...
}:
{
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  services.mako.enable = true;
  home.pointerCursor.size = 24;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      exec-once = [
        "${pkgs.foot}/bin/foot --server"
        "${pkgs.waybar}/bin/waybar"
      ];
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, ${pkgs.foot}/bin/footclient -N || ${pkgs.foot}/bin/foot"
        "$mod, Space, exec, ${pkgs.fuzzel}/bin/fuzzel"
        "$mod, Tab, layoutmsg, swapwithmaster"
        "$mod, f, fullscreen, 1"
        "$mod, q, killactive"
        "$mod CONTROL, q, exit"

        # workspace
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, x, exec, loginctl lock-session"

        (
          ", Print, exec, "
          + "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - |"
          + "${pkgs.wl-clipboard}/bin/wl-copy -t image/png"
        )
        ", XF86AudioMute, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        (
          ", XF86AudioLowerVolume, exec, "
          + "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ 0 && "
          + "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
        )
        (
          ", XF86AudioRaiseVolume, exec, "
          + "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ 0 && "
          + "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
        )
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"

        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
      ];
      binde = [
        "$mod, h, resizeactive, -50 0"
        "$mod, l, resizeactive, 50 0"
        "$mod SHIFT, h, resizeactive, -5 0"
        "$mod SHIFT, l, resizeactive, 5 0"
        "$mod, k, layoutmsg, cycleprev"
        "$mod, j, layoutmsg, cyclenext"
        "$mod SHIFT, k, layoutmsg, swapprev"
        "$mod SHIFT, j, layoutmsg, swapnext"
      ];
      input = {
        kb_options = "ctrl:nocaps,altwin:swap_alt_win";
        repeat_delay = 250;
        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.175;
        };
      };
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
        layout = "master";
      };
      animations = {
        animation = [
          "global, 1, 4, default"
        ];
      };
      master = {
        new_status = "master";
        mfact = 0.6;
      };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
      xwayland = {
        force_zero_scaling = true;
      };
    };
  };
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        disable_loading_bar = true;
      };
    };
  };
  programs.waybar = {
    enable = true;
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "${pkgs.hyprlock}/bin/hyprlock";
      };

      listener = [
        {
          timeout = 120;
          on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
        }
        {
          timeout = 180;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
  programs.fuzzel = {
    enable = true;
  };
  programs.foot = {
    enable = true;
    settings = {
      scrollback = {
        multiplier = 8;
      };
      text-bindings = {
        "\\x0a" = "Shift+Return Control+Return Shift+Control+Return";
        "\\x09" = "Control+Tab";
      };
    };
  };
  programs.neovim.extraPackages = [
    pkgs.wl-clipboard
  ];

  xdg.userDirs = {
    enable = true;
  };
}
