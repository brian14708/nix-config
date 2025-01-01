{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../profiles/linux.nix
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
    secrets."smartdns" = {
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
        extraGroups = [
          "wheel"
          "video"
        ] ++ (if config.virtualisation.docker.enable then [ "docker" ] else [ ]);
        openssh.authorizedKeys.keys = user.ssh;
        hashedPasswordFile = config.sops.secrets."brian/password".path;
      };
  };

  hardware.enableRedistributableFirmware = true;
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "lock";
    lidSwitchDocked = "lock";
  };
  services.chrony = {
    enable = true;
  };

  powerManagement.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      "DEVICES_TO_ENABLE_ON_STARTUP" = "bluetooth wifi";
    };
  };
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];
}
