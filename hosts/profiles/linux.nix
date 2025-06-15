{
  pkgs,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };
  documentation.doc.enable = false;
  programs.nix-ld.enable = true;
  nix.settings = {
    trusted-users = [ "@wheel" ];
    allowed-users = [ "@users" ];
  };

  services = {
    dbus.implementation = "broker";
    speechd.enable = false;
    openssh.enable = true;
  };

  users.users = {
    root = {
      hashedPassword = "!";
    };
  };
}
