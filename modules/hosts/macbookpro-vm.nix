{
  inputs,
  config,
  ...
}:
let
  hm = config.flake.modules.homeManager;
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.homeManager."hosts/macbookpro-vm" =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = with hm; [
        workstation-linux
        niri
        fcitx5
        media
        chromium
        cli
        catppuccin
      ];

      my.desktop.enable = true;

      programs.hyprlock.enable = lib.mkForce false;
      wayland.windowManager.niri.settings.input.keyboard.xkb.options = lib.mkForce "";

      my.desktop.startupCommands = [
        [
          (builtins.toString (
            pkgs.writeShellScript "spice-vdagent-retry.sh" ''
              #!${pkgs.runtimeShell}
              while true; do
                ${pkgs.spice-vdagent}/bin/spice-vdagent -x
                sleep 1
              done
            ''
          ))
        ]
      ];

      wayland.windowManager.niri.settings = {
        "output \"Virtual-1\"" = {
          scale = 2;
        };
        input.mouse = {
          natural-scroll = [ ];
        };
      };
    };

  flake.modules.nixos."hosts/macbookpro-vm" =
    {
      pkgs,
      lib,
      modulesPath,
      config,
      ...
    }:
    let
      inherit (config) owner;
    in
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        inputs.disko.nixosModules.disko
      ]
      ++ (with nixos; [
        workstation
        locale-cn
        sops
        niri
        mihomo
        tailscale-subnet
        home-manager
        stylix
      ]);

      nixpkgs.hostPlatform = "aarch64-linux";

      disko.devices = {
        disk.vda = {
          type = "disk";
          device = "/dev/vda";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };

              swap = {
                size = "8G";
                content = {
                  type = "swap";
                };
              };
            };
          };
        };
      };

      boot = {
        kernelParams = [ "mitigations=off" ];
        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 5;
            editor = false;
          };
          efi.canTouchEfiVariables = true;
        };
      };

      services = {
        tailscale.enable = true;
        openssh.enable = true;
        qemuGuest.enable = true;
        spice-vdagentd.enable = true;
      };
      networking = {
        hostName = "macbookpro-vm";
        networkmanager.enable = true;
        firewall.enable = false;
      };

      users = {
        mutableUsers = false;
        users = {
          root.hashedPassword = "!";
          ${owner.username} = {
            uid = 1000;
            description = owner.name;
            isNormalUser = true;
            extraGroups = [
              "video"
              "wheel"
            ];
            openssh.authorizedKeys.keys = owner.ssh;
          };
        };
      };

      stylix.enable = true;

      environment.systemPackages = with pkgs; [
        ghostty.terminfo
      ];

      hardware.graphics.enable = true;

      system.stateVersion = "25.05";
    };
}
