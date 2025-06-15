{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../../../profiles/base
    ../../../features/desktop/niri
    ../../../features/desktop/hyprland
    ../../../features/desktop/fcitx5
    ../../../features/desktop/media
    ../../../features/desktop/chromium
    ../../../features/development/cli
    ../../../features/themes/catppuccin
  ];

  home = {
    username = "brian";
    stateVersion = "25.05";
  };
  my.desktop.enable = true;
  sops = {
    defaultSopsFile = ../secrets.yaml;
    environment.SOPS_GPG_EXEC = "/dev/null";
    age.sshKeyPaths = [ ];
    age.keyFile = "/home/brian/.config/sops/age/keys.txt";
    gnupg.sshKeyPaths = [ ];
    secrets."ssh" = {
      path = "/home/brian/.ssh/id_ed25519";
    };
  };
  programs.hyprlock.enable = lib.mkForce false;
  wayland.windowManager.niri.settings.input.keyboard.xkb.options = lib.mkForce "";
  my.desktop.startupCommands = [
    (builtins.toString (
      pkgs.writeShellScript "spice-vdagent-retry.sh" ''
        #!${pkgs.runtimeShell}
        while true; do
          ${pkgs.spice-vdagent}/bin/spice-vdagent -x
          sleep 1
        done
      ''
    ))
  ];
  wayland.windowManager.niri = {
    settings = {
      "output \"Virtual-1\"" = {
        scale = 2;
      };
      input.mouse = {
        natural-scroll = [ ];
      };
    };
  };
}
