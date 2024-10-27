{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  flavor = "mocha";
  accent = "blue";
  mkUpper =
    str:
    (lib.toUpper (builtins.substring 0 1 str)) + (builtins.substring 1 (builtins.stringLength str) str);
in
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin.flavor = flavor;
  catppuccin.accent = accent;
  catppuccin.enable = true;
  catppuccin.pointerCursor = {
    enable = true;
    accent = "dark";
  };
  home.packages = with pkgs; [
    # fonts
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Inter"
        "Noto Sans"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
      monospace = [
        "CaskaydiaCove Nerd Font"
        "Noto Sans Mono"
        "Noto Sans Mono CJK SC"
      ];
    };
  };
  gtk = {
    catppuccin.icon.enable = true;
  };
  programs.chromium = {
    extensions = [
      # Catppuccin Chrome Theme - Mocha
      { id = "bkkmolkhemgaeaeggcmfbghljjjoofoh"; }
    ];
  };
  i18n.inputMethod = {
    fcitx5 = {
      catppuccin.enable = false;
      addons = with pkgs; [
        catppuccin-fcitx5
      ];
    };
  };
  xdg.configFile."fcitx5/conf/classicui.conf" = {
    text = lib.generators.toINIWithGlobalSection { } {
      globalSection.Theme = "catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}";
    };
  };

  wayland.windowManager.hyprland = {
    settings.general = {
      "col.active_border" = "$accent";
      "col.inactive_border" = "$overlay0";
    };
  };
  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        spacing = 0;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ ];
        modules-right = [
          "pulseaudio"
          "network"
          "memory"
          "battery"
          "clock"
          "tray"
        ];
        "hyprland/workspaces" = {
          sort-by-number = true;
          on-click = "activate";
        };
        pulseaudio = {
          tooltip = false;
          format = "VOL {volume}%";
          format-muted = "MUTE";
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
        tray = {
          icon-size = 14;
          spacing = 10;
        };
        clock = {
          format = "{:%Y-%m-%d %H:%M}";
        };
        battery = {
          tooltip = false;
          format = "BAT {capacity}%";
          format-charging = "CHR {capacity}%";
          format-full = "FULL";
        };
        memory = {
          tooltip = false;
          format = "MEM {}%";
        };
        network = {
          tooltip = false;
          format = "{ipaddr}";
          format-disconnected = "WLAN DISCONNECTED";
        };
      };
    };
    style = ''
      * {
        font-family: monospace;
        font-size: 12px;
      }

      #waybar {
        background: @base;
        color: @text;
      }

      #workspaces button {
        padding: 0 5px;
        color: @surface2;
        border: none;
        border-radius: 0;
        background: transparent;
        box-shadow: none;
        text-shadow: none;
      }

      #workspaces button.active {
        color: @text;
      }

      #workspaces button.urgent {
        color: @red;
      }

      #workspaces button:hover {
        color: @sapphire;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #mpd {
          padding: 0 10px;
      }
    '';
  };
  programs.fuzzel = {
    settings = {
      border = {
        width = 2;
        radius = 0;
      };
    };
  };
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=10";
      };
      colors = {
        alpha = 0.9;
      };
    };
  };
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
    ];
    userSettings = {
      "workbench.colorTheme" = "Catppuccin ${mkUpper flavor}";
      "catppuccin.accentColor" = accent;
      "workbench.iconTheme" = "catppuccin-${flavor}";
      "editor.fontFamily" = "monospace";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 13;
    };
  };
  programs.neovim.lua.theme = ''
    return {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        flavor = "${flavor}",
        transparent_background = true,
      },
      init = function()
        vim.cmd.colorscheme("catppuccin")
      end,
    };
  '';
}
