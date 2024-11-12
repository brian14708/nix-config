{
  pkgs,
  ...
}:
{
  imports = [ ./common ];
  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      colima
      docker-client
      nil
      nixfmt-rfc-style
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];
  };
  programs.zsh.enable = true;
  programs.direnv.enable = true;
  programs.starship.enable = true;
}
