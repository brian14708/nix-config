{
  pkgs,
  ...
}:
{
  services.mako.enable = true;
  home.pointerCursor.size = 24;
  my.desktop = {
    enable = true;
    startupCommands = [
      "foot --server"
      "${pkgs.waybar}/bin/waybar"
    ];
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
  services.hypridle =
    let
      timeoutCommand = builtins.toString (
        pkgs.writeScript "timeout-command" ''
          #!${pkgs.dash}/bin/dash
          case "$XDG_CURRENT_DESKTOP" in
          niri) niri msg action power-off-monitors ;;
          Hyprland) hyprctl dispatch dpms off ;;
          esac
        ''
      );
      resumeCommand = builtins.toString (
        pkgs.writeScript "resume-command" ''
          #!${pkgs.dash}/bin/dash
          case "$XDG_CURRENT_DESKTOP" in
          niri) niri msg action power-on-monitors ;;
          Hyprland) hyprctl dispatch dpms on ;;
          esac
        ''
      );
    in
    {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = resumeCommand;
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        };

        listener = [
          {
            timeout = 120;
            on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
          }
          {
            timeout = 180;
            on-timeout = timeoutCommand;
            on-resume = resumeCommand;
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
        multiplier = 4;
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
  gtk = {
    enable = true;
  };
}
