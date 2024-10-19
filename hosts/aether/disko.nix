{
  disko.devices = {
    disk.nvme = {
      type = "disk";
      device = "/dev/nvme0n1";
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
              type = "luks";
              name = "root";
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "btrfs";
                subvolumes = {
                  "@" = { };
                  "@/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@/persist" = {
                    mountpoint = "/nix/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "noexec"
                    ];
                  };
                  "@/swap" = {
                    mountpoint = "/nix/swap";
                    swap.swapfile.size = "32G";
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };
    nodev."/home" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=777"
      ];
    };
  };
}
