{
  pkgs,
  ...
}:
{
  imports = [ ../profiles/base ];
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
  programs.gpg.enable = true;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets."ssh" = {
      path = "/Users/brian/.ssh/id_ed25519";
    };
    secrets."nix-access-tokens" = { };
  };
}
