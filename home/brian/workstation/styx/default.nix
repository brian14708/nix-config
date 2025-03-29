{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../base-linux.nix
    ../../features/desktop/hyprland
    ../../features/desktop/fcitx5
    ../../features/desktop/media
    ../../features/desktop/chromium
    ../../features/development/vscode
    ../../features/development/emacs
    ../../features/development/cli
    ../../features/themes/catppuccin
  ];

  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      obsidian
    ];
  };
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  wayland.windowManager.hyprland = {
    settings = {
      env = [
        "AQ_DRM_DEVICES,/dev/dri/card1"
      ];
      monitor = [
        "desc:AOC Q2790PQ PSKP5HA003512, 2560x1440, auto, 1.6"
        "eDP-1, preferred, auto, 2"
      ];
      bindl = [
        '',switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, preferred, auto, auto"''
        '',switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"''
      ];
    };
  };
  services.nix-store-gateway = {
    enable = true;
    config = config.sops.secrets.nix-store-gateway.path;
  };
}
