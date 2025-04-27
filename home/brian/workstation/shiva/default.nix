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
    pinentry.package = pkgs.pinentry-tty;
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
        "eDP-1, preferred, auto, 2"
        "desc:AOC Q2790PQ PSKP5HA003512, preferred, auto, 1.6"
      ];
    };
  };
  services.nix-store-gateway = {
    enable = true;
    config = config.sops.secrets.nix-store-gateway.path;
  };
}
