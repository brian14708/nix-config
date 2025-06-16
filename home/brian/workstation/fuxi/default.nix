{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../base-linux.nix
    ../../features/desktop/niri
    ../../features/desktop/fcitx5
    ../../features/desktop/media
    ../../features/desktop/chromium
    ../../features/development/vscode
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
  services.nix-store-gateway = {
    enable = true;
    config = config.sops.secrets.nix-store-gateway.path;
  };
  wayland.windowManager.niri = {
    settings = {
      "output \"eDP-1\"" = {
        scale = 2.0;
      };
      "output \"Dell Inc. DELL D2720DS 8QHGNS2\"" = {
        scale = 1.5;
      };
    };
  };
}
