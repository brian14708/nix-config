{
  config,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ../../../profiles/linux.nix
    ../../../features/locale/cn.nix
    ../../../features/desktop/niri.nix
    ../../../features/network/mihomo.nix
    ../../../features/network/tailscale-subnet.nix
    ../../../features/network/dns.nix
  ];

  boot = {
    kernelParams = [ "mitigations=off" ];
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
      editor = false;
    };
    loader.efi.canTouchEfiVariables = true;
  };

  services.tailscale = {
    enable = true;
  };
  networking.hostName = "macbookpro-vm";
  networking.networkmanager.enable = true;

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
          "video"
          "wheel"
        ];
        openssh.authorizedKeys.keys = user.ssh;
        hashedPasswordFile = config.sops.secrets."brian/password".path;
      };
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.brian = {
      imports = [
        ../../../../home/brian/workstation/mbp/vm
      ];
      home = {
        stateVersion = "25.05";
        username = "brian";
      };
    };
  };
  stylix.enable = true;

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  services.openssh.enable = true;
  networking.firewall.enable = false;
  system.stateVersion = "25.05";
  users.mutableUsers = false;

  hardware.graphics.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  sops = {
    age.sshKeyPaths = [ ];
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    gnupg.sshKeyPaths = [ ];
    defaultSopsFile = ../secrets.yaml;
    secrets."brian/password" = {
      neededForUsers = true;
      sopsFile = ../../secrets.yaml;
    };
    secrets."unbound" = {
      sopsFile = ../../secrets.yaml;
      mode = "0444";
    };
    secrets."smartdns" = {
      sopsFile = ../../secrets.yaml;
    };
    secrets."mihomo-url" = {
      sopsFile = ../../secrets.yaml;
    };
    secrets."dae-url" = {
      sopsFile = ../../secrets.yaml;
    };
    secrets."brian/sops" = {
      owner = "brian";
      path = "/home/brian/.config/sops/age/keys.txt";
    };
  };
}
