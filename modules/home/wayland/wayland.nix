{
  flake.modules.homeManager.wayland =
    { pkgs, lib, ... }:
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
      home.pointerCursor.enable = true;
      home.pointerCursor.size = 24;

      my.desktop = {
        enable = true;
        startupCommands = [
          [ (lib.getExe pkgs.waybar) ]
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
        ghostty = {
          enable = true;
          settings = {
            scrollback-limit = 10000;
            app-notifications = false;
          };
        };
        neovim.extraPackages = [
          pkgs.wl-clipboard
        ];
      };

      services = {
        mako = {
          enable = true;
          settings = {
            "default-timeout" = 5000;
          };
        };
        hypridle = {
          enable = true;
          settings = {
            general = {
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = resumeCommand;
              lock_cmd = "pidof hyprlock || ${lib.getExe pkgs.hyprlock}";
            };

            listener = [
              {
                timeout = 120;
                on-timeout = lib.getExe pkgs.hyprlock;
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
