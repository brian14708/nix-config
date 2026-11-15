{
  flake.modules.homeManager.wayland =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      displayPowerCommand =
        name: niriAction: hyprlandState:
        lib.getExe (
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs =
              lib.optional config.wayland.windowManager.niri.enable config.wayland.windowManager.niri.package
              ++ lib.optional config.wayland.windowManager.hyprland.enable config.wayland.windowManager.hyprland.package;
            text = ''
              case ":''${XDG_CURRENT_DESKTOP:-}:" in
                *:niri:*) niri msg action ${niriAction} ;;
                *:Hyprland:*) hyprctl dispatch dpms ${hyprlandState} ;;
              esac
            '';
          }
        );
      timeoutCommand = displayPowerCommand "desktop-displays-off" "power-off-monitors" "off";
      resumeCommand = displayPowerCommand "desktop-displays-on" "power-on-monitors" "on";
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
            working-directory = "home";
            window-inherit-working-directory = false;
          };
        };
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
              before_sleep_cmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
              after_sleep_cmd = resumeCommand;
              lock_cmd = "${lib.getExe' pkgs.procps "pidof"} hyprlock || ${lib.getExe config.programs.hyprlock.package}";
            };

            listener = [
              {
                timeout = 120;
                on-timeout = lib.getExe config.programs.hyprlock.package;
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
