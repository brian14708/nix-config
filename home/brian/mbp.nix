{
  pkgs,
  ...
}:
{
  imports = [ ./common ];
  home = {
    username = "brian";
    stateVersion = "24.05";
    packages = with pkgs; [
      colima
      docker-client
      nil
      nixfmt-rfc-style
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    ];
  };
}
