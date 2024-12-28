{ ... }:
{
  imports = [
    ../base-darwin.nix
  ];
  system.stateVersion = 5;
  services.nix-daemon.enable = true;
  nix = {
    settings = {
      trusted-users = [ "brian" ];
    };
  };
  homebrew.enable = true;
  programs.zsh.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  homebrew.casks = [
    "tailscale"
    "ghostty"
    "alfred"
    "surge"
    "1password"
  ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
}
