{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../base-linux.nix
    ../../features/development/cli
    ../../features/themes/catppuccin
  ];

  home = {
    username = "brian";
    stateVersion = "24.11";
  };
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  services.nix-store-gateway = {
    enable = true;
    config = config.sops.secrets.nix-store-gateway.path;
  };
}
