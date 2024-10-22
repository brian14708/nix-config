{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common
  ];
  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      chromium
      alacritty

      # fonts
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      tofi
    ];
  };
  programs.bash.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, footclient -N || foot"
        "$mod, Space, exec, tofi-run | xargs hyprctl dispatch exec --"
      ];
    };
  };

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      font = "code";
      fontSize = 10;
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sans = [
        "Inter"
        "Noto Sans"
        "Noto Color Emoji"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
      ];
      code = [
        "CaskaydiaCove Nerd Font"
        "Noto Color Emoji"
        "Noto Sans Mono"
        "Noto Sans Mono CJK SC"
      ];
      monospace = [
        "Noto Sans Mono"
        "Noto Sans Mono CJK SC"
      ];
    };
  };

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
}
