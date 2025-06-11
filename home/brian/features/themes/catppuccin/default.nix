{
  pkgs,
  config,
  lib,
  ...
}:
let
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images/astronaut.jpg";
    hash = "sha256-32KrCjEoLigs8nPFE6M8lLwUbjOdg2LwMAQtX3mYmSo=";
  };
  flavor = "mocha";
  codeFont = "Maple Mono NF CN";
  accent = "blue";
  mkUpper =
    str:
    (lib.toUpper (builtins.substring 0 1 str)) + (builtins.substring 1 (builtins.stringLength str) str);
in
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${flavor}.yaml";
    fonts = {
      serif = {
        name = "serif";
      };
      sansSerif = {
        name = "sans-serif";
      };
      monospace = {
        name = "monospace";
      };
      emoji = {
        name = "emoji";
      };
      sizes.terminal = 10;
    };
    opacity.terminal = 0.9;
  };
  home.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.caskaydia-mono
    maple-mono.NF-CN
    adwaita-icon-theme
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
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "CaskaydiaMono Nerd Font"
        "Noto Sans Mono"
        "Noto Sans Mono CJK SC"
      ];
    };
  };

  my.desktop.wallpaper = wallpaper;
  stylix.cursor =
    let
      accent = if flavor == "latte" then "light" else "dark";
    in
    {
      name = "catppuccin-${flavor}-${accent}-cursors";
      package = pkgs.catppuccin-cursors.${flavor + mkUpper accent};
      size = 24;
    };
  programs.chromium = {
    extensions = [
      # Catppuccin Chrome Theme
      {
        id =
          {
            latte = "jhjnalhegpceacdhbplhnakmkdliaddd";
            frappe = "olhelnoplefjdmncknfphenjclimckaf";
            macchiato = "cmpdlhmnmjhihmcfnigoememnffkimlk";
            mocha = "bkkmolkhemgaeaeggcmfbghljjjoofoh";
          }
          .${flavor};
      }
    ];
  };
  xdg.configFile."nvim/override/lua/theme.lua" = {
    text = ''
      vim.g.neovide_opacity = 0.8
      vim.g.neovide_normal_opacity = 0.8
      vim.g.neovide_padding_top = 4
      vim.g.neovide_padding_bottom = 4
      vim.g.neovide_padding_right = 4
      vim.g.neovide_padding_left = 4

      return {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
          flavor = "${flavor}",
          term_colors = true,
          transparent_background = not vim.g.neovide,
        },
        init = function()
          vim.cmd.colorscheme("catppuccin")
        end,
      };
    '';
  };
  programs.foot = {
    settings = {
      main = {
        font = lib.mkForce "${codeFont}:size=${toString config.stylix.fonts.sizes.terminal}";
      };
    };
  };
  programs.vscode.profiles.default = {
    userSettings = {
      "editor.fontFamily" = lib.mkForce codeFont;
      "editor.fontLigatures" = true;
    };
  };
  programs.zed-editor = {
    userSettings = {
      buffer_font_family = lib.mkForce "${codeFont}";
    };
  };
  programs.neovide = {
    settings = {
      fork = true;
      font = {
        normal = lib.mkForce [ codeFont ];
        size = 10;
      };
      theme = "dark";
    };
  };
  stylix.targets.waybar.enable = false;
  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        spacing = 0;
        modules-left = [
          "hyprland/workspaces"
          "niri/workspaces"
        ];
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
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
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
        background: transparent;
        color: #9399b2;
      }

      #workspaces button {
        padding: 0 5px;
        color: #585b70;
        border: none;
        border-radius: 0;
        background: transparent;
        box-shadow: none;
        text-shadow: none;
      }

      #workspaces button.active {
        color: #9399b2;
      }

      #workspaces button.urgent {
        color: #f38ba8;
      }

      #workspaces button:hover {
        color: #74c7ec;
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
  stylix.targets.fcitx5.enable = false;
  i18n.inputMethod = {
    fcitx5 = {
      addons = [ pkgs.catppuccin-fcitx5 ];
      settings.addons.classicui.globalSection.Theme = "catppuccin-${flavor}-${accent}";
    };
  };
}
