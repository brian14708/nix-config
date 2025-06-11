{
  lib,
  config,
  pkgs,
  ...
}:
let
  launcher = "uwsm app -- ";
in
{
  imports = [ ../wayland ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = false;
      variables = [ "NIXOS_OZONE_WL" ];
    };
    settings = {
      exec-once = [
      ]
      ++ (lib.lists.map (cmd: "${launcher} ${cmd}") config.my.desktop.startupCommands);
      "$mod" = "SUPER";
      env = [
        "NIXOS_OZONE_WL,1"
      ];
      bind = [
        "$mod, Return, exec, footclient -N || ${launcher} foot"
        "$mod, Space, exec, ${pkgs.fuzzel}/bin/fuzzel --launch-prefix=\"${launcher}\""
        "$mod, Tab, layoutmsg, swapwithmaster"
        "$mod, f, fullscreen, 1"
        "$mod SHIFT, f, fullscreen, 0"
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
          "$mod, P, exec, "
          + "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - |"
          + "${pkgs.wl-clipboard}/bin/wl-copy -t image/png"
        )
        (
          ", Print, exec, "
          + "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - |"
          + "${pkgs.wl-clipboard}/bin/wl-copy -t image/png"
        )
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"
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
      monitor = [
        "FALLBACK,1920x1080@60,auto,1"
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
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
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
}
