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
  nix.settings = {
    trusted-users = [ "@wheel" ];
    allowed-users = [ "@users" ];
  };

  services = {
    dbus.implementation = "broker";
    speechd.enable = false;
    openssh.enable = true;
  };
  zramSwap.enable = true;

  users.users = {
    root = {
      hashedPassword = "!";
    };
  };
}
