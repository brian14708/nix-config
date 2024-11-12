{ pkgs, ... }:
{
  imports = [
    ./homebrew-mirror.nix
  ];
  system.stateVersion = 5;
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixVersions.latest;
    gc.automatic = true;
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      trusted-users = [ "brian" ];
    };
  };
  homebrew.enable = true;
  programs.zsh.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  homebrew.casks = [
    "tailscale"
    "iterm2"
    "alfred"
    "surge"
    "1password"
  ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
}
