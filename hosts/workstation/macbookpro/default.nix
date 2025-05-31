{
  imports = [
    ../base-darwin.nix
  ];
  system.stateVersion = 5;
  nix = {
    settings = {
      trusted-users = [ "brian" ];
    };
  };
  homebrew = {
    enable = true;
    user = "brian";
  };
  programs.zsh.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  homebrew.casks = [
    "tailscale"
    "ghostty"
    "alfred"
    "surge"
    "1password"
    "obsidian"
  ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
}
