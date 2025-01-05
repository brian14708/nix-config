{
  pkgs,
  ...
}:
{
  imports = [ ../../profiles/base ];
  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      colima
      docker-client
      nil
      nixfmt-rfc-style
      nerd-fonts.caskaydia-mono
    ];
  };
  programs.zsh.enable = true;
  programs.direnv.enable = true;
  programs.starship.enable = true;
  programs.gpg.enable = true;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    environment.SOPS_GPG_EXEC = "/dev/null";
    age.sshKeyPaths = [ ];
    age.keyFile = "/Users/brian/.config/sops/age/keys.txt";
    gnupg.sshKeyPaths = [ ];
    secrets."ssh" = {
      path = "/Users/brian/.ssh/id_ed25519";
    };
  };
  xdg.configFile."ghostty/config".text = ''
    font-family = "CaskaydiaMono Nerd Font Mono"
    theme = "catppuccin-mocha"
  '';
}
