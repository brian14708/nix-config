{ ... }:
{
  imports = [
    ../profiles/darwin.nix
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
    "iterm2"
    "alfred"
    "surge"
    "1password"
  ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
}
