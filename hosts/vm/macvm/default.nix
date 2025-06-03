{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    ../../profiles/linux.nix
    ../../features/locale/cn.nix
    ./disko.nix
    ../../features/desktop/hyprland.nix
    (modulesPath + "/virtualisation/qemu-vm.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernelParams = [ "mitigations=off" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
  services.tailscale = {
    enable = true;
  };
  networking.hostName = "macvm";
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
        initialPassword = "";
      };
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.brian = {
      imports = [
        ../../../home/brian/vm/devvm
      ];
      home = {
        stateVersion = "25.05";
        username = "brian";
      };
    };
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

  environment.systemPackages = with pkgs; [
  ];

  services.openssh.enable = true;
  networking.firewall.enable = false;
  system.stateVersion = "25.05";
  users.mutableUsers = false;

  virtualisation.qemu.options = [
    "-vga none"
    "-device virtio-gpu-gl-pci"
    "-display gtk,gl=on,grab-on-hover=on"
  ];
  hardware.graphics.enable = true;
  services.greetd.settings = {
    initial_session = {
      command = "niri-session";
      user = "brian";
    };
  };
}
