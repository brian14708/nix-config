{
  config.flake.factory.disko-workstation =
    {
      diskName ? "nvme",
      device ? "/dev/nvme0n1",
      efiSize ? "512M",
      bootMountpoint ? "/boot",
      luksName ? "root",
      swapSize ? "32G",
      compression ? "zstd",
    }:
    let
      btrfsMountOptions = [
        "compress=${compression}"
        "noatime"
        "ssd"
        "discard=async"
      ];
    in
    {
      disko.devices = {
        disk = {
          "${diskName}" = {
            type = "disk";
            inherit device;
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  type = "EF00";
                  size = efiSize;
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = bootMountpoint;
                    mountOptions = [ "umask=0077" ];
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = luksName;
                    settings.allowDiscards = true;
                    content = {
                      type = "btrfs";
                      subvolumes = {
                        "@" = { };
                        "@/root" = {
                          mountpoint = "/";
                          mountOptions = btrfsMountOptions;
                        };
                        "@/home" = {
                          mountpoint = "/home";
                          mountOptions = btrfsMountOptions;
                        };
                        "@/nix" = {
                          mountpoint = "/nix";
                          mountOptions = btrfsMountOptions;
                        };
                        "@/swap" = {
                          mountpoint = "/nix/swap";
                          swap.swapfile.size = swapSize;
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
