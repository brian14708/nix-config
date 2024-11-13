{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ../../../modules/home/desktop/hyprland
    ../../../modules/home/desktop/fcitx5
    ../../../modules/home/desktop/media
    ../../../modules/home/development/vscode
    ../../../modules/home/development/emacs
    ../../../modules/home/themes/catppuccin
  ];

  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      cachix
      android-studio
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
