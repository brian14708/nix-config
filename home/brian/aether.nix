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
      firefox
      kitty
    ];
  };
  programs.bash.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
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
