{
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

  catppuccin = {
    inherit flavor accent;
    enable = true;
    pointerCursor = {
      enable = true;
      accent = "dark";
    };
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
      (inputs.catppuccin-vsc.packages.${pkgs.system}.catppuccin-vsc.override {
        accent = accent;
      })
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
  xdg.configFile."nvim/override/lua/theme.lua" = {
    text = ''
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
  };
  programs.hyprlock.settings = {
    background = {
      color = "$base";
    };
    input-field = [
      {
        monitor = "";
        size = "250, 60";
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "$accent";
        inner_color = "$surface0";
        font_color = "$text";
        fade_on_empty = false;
        placeholder_text = ''<span foreground="##$textAlpha">󰌾</span>'';
        hide_input = false;
        check_color = "$accent";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -120";
        halign = "center";
        valign = "center";
      }
    ];
    label = [
      {
        monitor = "";
        text = "$TIME";
        font_size = 120;
        color = "$text";
        position = "0, 80";
        valign = "center";
        halign = "center";
      }
    ];
  };
  programs.emacs = {
    extraPackages =
      epkgs: with epkgs; [
        catppuccin-theme
      ];
    extraConfig = lib.mkAfter ''
      (setq catppuccin-flavor '${flavor})
      (load-theme 'catppuccin :no-confirm)
    '';
  };
  programs.eza = {
    icons = "auto";
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };
}
