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
  wallpaper =
    (pkgs.callPackage "${inputs.nixpkgs}/pkgs/data/misc/nixos-artwork" { })
    .wallpapers."catppuccin-${flavor}".passthru.gnomeFilePath;
  codeFont = "Maple Mono NF CN";
in
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin = {
    inherit flavor accent;
    enable = true;
    gtk.icon.enable = true;
    nvim.enable = false;
    vscode.enable = false;
  };
  home.pointerCursor =
    let
      accent = if flavor == "latte" then "light" else "dark";
    in
    {
      name = "catppuccin-${flavor}-${accent}-cursors";
      package = pkgs.catppuccin-cursors.${flavor + mkUpper accent};
    };

  home.packages = with pkgs; [
    # fonts
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.caskaydia-mono
    maple-mono.NF-CN
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
        "CaskaydiaMono Nerd Font"
        "Noto Sans Mono"
        "Noto Sans Mono CJK SC"
      ];
    };
  };
  gtk.theme =
    let
      themeAccent =
        if
          (builtins.elem accent [
            "purple"
            "pink"
            "red"
            "orange"
            "yellow"
            "green"
            "teal"
            "grey"
          ])
        then
          accent
        else
          "default";
    in
    {
      name =
        "Catppuccin-GTK"
        + (if themeAccent == "default" then "" else "-${mkUpper themeAccent}")
        + (if flavor == "latte" then "-Light" else "-Dark");
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ themeAccent ];
        shade = if flavor == "latte" then "light" else "dark";
        tweaks =
          [ ]
          ++ (if flavor == "frappe" then [ "frappe" ] else [ ])
          ++ (if flavor == "macchiato" then [ "macchiato" ] else [ ]);
      };
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

  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [
        "${pkgs.swaybg}/bin/swaybg -i ${wallpaper}"
      ];
      general = {
        "col.active_border" = "$accent";
        "col.inactive_border" = "$overlay0";
      };
    };
  };
  catppuccin.hyprlock.useDefaultConfig = false;
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
        font_family = "monospace";
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
        font = "${codeFont}:size=10";
      };
      colors = {
        alpha = 0.9;
      };
    };
  };
  programs.vscode.profiles.default = {
    userSettings = {
      "editor.fontFamily" = codeFont;
      "editor.fontLigatures" = true;
      "editor.fontSize" = 13;
    };
  };
  programs.zed-editor = {
    userSettings = {
      buffer_font_family = "${codeFont}";
      buffer_font_size = 13;
    };
    extraPackages = [

    ];
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
        color-scheme = if flavor == "latte" then "prefer-light" else "prefer-dark";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  programs.lazygit = {
    settings = {
      gui.nerdFontsVersion = "3";
    };
  };

  i18n.inputMethod = {
    fcitx5 = {
      addons = [ pkgs.catppuccin-fcitx5 ];
    };
  };
}
