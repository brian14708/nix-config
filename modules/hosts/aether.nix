{ config, ... }:
let
  inherit (config.flake.modules) homeManager nixos;
in
{
  flake.modules.homeManager."hosts/aether" =
    { pkgs, ... }:
    {
      imports = with homeManager; [
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

  flake.modules.nixos."hosts/aether" = {
    imports = with nixos; [
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

    boot = {
      resumeDevice = "/dev/mapper/root";
      kernelParams = [
        "resume_offset=533760"
      ];
    };

    virtualisation.podman.enable = true;
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
