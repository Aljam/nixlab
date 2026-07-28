{ lib, ... }: {
  boot.zfs.devNodes = "/dev/disk/by-id";

  disko.devices = {
    disk = lib.genAttrs [
      "d1" "d2" "d3" "d4" "d5" "d6" "d7" "d8"
      "d9" "d10" "d11" "d12" "d13" "d14" "d15" "d16"
      "d17" "d18" "d19" "d20" "d21" "d22" "d23" "d24"
    ] (name: {
      type = "disk";
      # Map these dynamically or map exact /dev/disk/by-id strings
      device = "/dev/disk/by-id/your-disk-id-${name}"; 
    });

    zpool = {
      mediapool = {
        type = "zpool";
        mode = {
          val = lib.concatStringsSep " " [
            "raidz2" "d1" "d2" "d3" "d4" "d5" "d6" "d7" "d8"
            "raidz2" "d9" "d10" "d11" "d12" "d13" "d14" "d15" "d16"
            "raidz2" "d17" "d18" "d19" "d20" "d21" "d22" "d23" "d24"
          ];
        };
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          mountpoint = "none";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          media = {
            type = "zfs_fs";
            mountpoint = "/mnt/media";
          };
        };
      };
    };
  };
}
