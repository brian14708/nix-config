{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    "${inputs.impermanence}/home-manager.nix"
    ./global
  ];
  home.username = "brian";
  home.stateVersion = "24.11";

  home.packages =
    with pkgs;
    [
    ];

  home.persistence."/nix/persist/home/brian" = {
    directories = [
      ".ssh"
      "downloads"
    ];
    allowOther = true;
  };
}
