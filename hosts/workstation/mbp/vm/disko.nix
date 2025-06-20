{
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
}
