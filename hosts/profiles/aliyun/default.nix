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
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.home-manager.nixosModules.home-manager
    ../linux
  ];

  system.stateVersion = lib.mkDefault "24.11";

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      authKeyFile = "/run/secrets/tailscale_key";
    };
    cloud-init = {
      enable = true;
      settings = {
        datasource_list = [ "AliYun" ];
      };
    };
  };
  systemd.services.tailscaled-autoconnect.after = [ "cloud-final.service" ];

  users.users.ops = {
    uid = 2000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = config.userinfos.brian.ssh;
  };

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot = {
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
    loader.grub = {
      device =
        if (pkgs.stdenv.system == "x86_64-linux") then
          (lib.mkDefault "/dev/vda")
        else
          (lib.mkDefault "nodev");
      efiSupport = lib.mkIf (pkgs.stdenv.system != "x86_64-linux") (lib.mkDefault true);
      efiInstallAsRemovable = lib.mkIf (pkgs.stdenv.system != "x86_64-linux") (lib.mkDefault true);
    };
    loader.timeout = 0;
  };

  system.build.qcow2 = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = "auto";
    format = "qcow2-compressed";
    partitionTableType = "hybrid";
  };
}
