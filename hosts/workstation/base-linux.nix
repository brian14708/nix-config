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
  zramSwap.enable = true;
  services.tailscale = {
    enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  systemd.coredump.enable = false;
  boot.kernel.sysctl."kernel.core_pattern" = "|/run/current-system/sw/bin/false";
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
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
    secrets."dae-url" = {
      sopsFile = ./secrets.yaml;
    };
    secrets."unbound" = {
      sopsFile = ./secrets.yaml;
      mode = "0444";
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
        ];
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
