{
  pkgs,
  ...
}:
{
  imports = [
    ../profiles/base
  ];

  home = {
    username = "brian";
    stateVersion = "24.11";
    packages = with pkgs; [
      cachix
    ];
  };
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets."ssh" = {
      path = "/home/brian/.ssh/id_ed25519";
    };
    secrets."nix-access-tokens" = { };
  };

  programs.bash.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
