{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ./common
    ../../modules/home/desktop/fcitx5
  ];
  catppuccin.flavor = "mocha";
  catppuccin.enable = true;
  catppuccin.pointerCursor = {
    enable = true;
    accent = "dark";
  };

  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      (chromium.override { commandLineArgs = [ "--enable-wayland-ime" ]; })
      alacritty

      # fonts
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
  };
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
  };

  programs.starship.enable = true;
  programs.bash.enable = true;
  programs.fuzzel = {
    enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      exec-once = [
        "${pkgs.foot}/bin/foot --server"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.swaybg}/bin/swaybg -i $(find ${config.xdg.userDirs.pictures}/wallpapers/ -type f | shuf -n 1)"
      ];
      monitor = ",preferred,auto,auto";
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
        "$mod, 0, workspace, 0"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 0"
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

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.waybar = {
    enable = true;
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
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.userDirs = {
    enable = true;
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/media/music";
    pictures = "${config.home.homeDirectory}/media/pictures";
    videos = "${config.home.homeDirectory}/media/videos";
    desktop = "${config.home.homeDirectory}/public";
    publicShare = "${config.home.homeDirectory}/public";
    templates = "${config.home.homeDirectory}/public";
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}
