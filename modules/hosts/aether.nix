{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager."hosts/aether" =
    { pkgs, ... }:
    {
      imports = with hm; [
        workstation-linux
        niri
        fcitx5
        media
        chromium
        vscode
        cli
        catppuccin
      ];

      home.packages = with pkgs; [ obsidian ];

      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-tty;
      };
    };

  flake.modules.nixos."hosts/aether" =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        workstation
        secureboot
        locale-cn
        mihomo
        niri
        intel
        stylix
        home-manager
        (config.flake.factory.disko-workstation {
          swapSize = "48G";
        })
      ];

      networking.hostName = "aether";
      system.stateVersion = "26.05";
      stylix.enable = true;

      virtualisation.podman.enable = true;
      boot.kernelPackages = pkgs.linuxPackages_testing;
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "vmd"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      hardware.cpu.intel.npu.enable = true;
    };
}
