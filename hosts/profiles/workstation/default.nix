{
  inputs,
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    ../linux.nix
  ];
  boot = {
    kernelParams = [ "mitigations=off" ];
    secureboot.enable = true;
  };
  services.tailscale = {
    enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [
    config.services.tailscale.interfaceName
  ];

  sops = {
    age.sshKeyPaths = [ ];
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    gnupg.sshKeyPaths = [ ];
    secrets."brian/password" = {
      neededForUsers = true;
      sopsFile = ./secrets.yaml;
    };
    secrets."mihomo-url" = {
      sopsFile = ./secrets.yaml;
    };
    secrets."brian/sops" = {
      owner = "brian";
      path = "/home/brian/.config/sops/age/keys.txt";
    };
  };
  users.mutableUsers = false;
  users.users = {
    brian =
      let
        user = config.userinfos.brian;
      in
      {
        uid = 1000;
        description = user.name;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = user.ssh;
        hashedPasswordFile = config.sops.secrets."brian/password".path;
      };
  };

  hardware.enableRedistributableFirmware = true;
}
