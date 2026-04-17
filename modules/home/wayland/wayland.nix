{
  flake.modules.homeManager.wayland =
    { pkgs, ... }:
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
      home.pointerCursor.size = 24;

      my.desktop = {
        enable = true;
        startupCommands = [
          [
            "foot"
            "--server"
          ]
          [ "${pkgs.waybar}/bin/waybar" ]
        ];
      };

      programs = {
        hyprlock = {
          enable = true;
          settings = {
            general = {
              hide_cursor = true;
              disable_loading_bar = true;
            };
          };
        };
        waybar.enable = true;
        fuzzel.enable = true;
        foot = {
          enable = true;
          settings = {
            scrollback.multiplier = 4;
            text-bindings = {
              "\\x0a" = "Shift+Return Control+Return Shift+Control+Return";
              "\\x09" = "Control+Tab";
            };
          };
        };
        neovim.extraPackages = [
          pkgs.wl-clipboard
        ];
      };

      services = {
        mako.enable = true;
        hypridle = {
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
      };

      xdg.userDirs = {
        enable = true;
        setSessionVariables = true;
      };

      gtk.enable = true;
    };
}
