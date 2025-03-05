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
    ../../features/development/vscode
    ../../features/development/emacs
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

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--enable-wayland-ime"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-oop-rasterization"
      "--enable-zero-copy"
      "--enable-accelerated-video-decode"
      "--password-store=basic"
      "--disable-sync-preferences"
      "--enable-features=WebUIDarkMode,VaapiVideoDecodeLinuxGL,VaapiVideoEncoder"
      "--disable-features=UseChromeOSDirectVideoDecoder"
    ];
    extensions = [
      # 1Password
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }
      # uBlock Origin Lite
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
      # Vimium
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; }
    ];
  };
  programs.bash.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  gtk = {
    enable = true;
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
