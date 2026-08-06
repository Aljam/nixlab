{ lib, ... }: {
  boot.zfs.devNodes = "/dev/disk/by-id";

  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5000c5007dd3fee3"; # Replace with actual disk ID
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "r730pool";
              };
            };
          };
        };
      };
      
      disk1 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5000c5007dd3fee3"; # Replace with actual disk ID
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot-fallback"; # Fallback EFI mount
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "r730pool";
              };
            };
          };
        };
      };
      disk2 = { type = "disk"; device = "/dev/disk/by-id/wwn-0x5000c5007dd70cb7"; };
      disk3 = { type = "disk"; device = "/dev/disk/by-id/wwn-0x5000c5007f119817"; };
      disk4 = { type = "disk"; device = "/dev/disk/by-id/wwn-0x5000c5007f1268cb"; };
      disk5 = { type = "disk"; device = "/dev/disk/by-id/wwn-0x5000c5007f138ae3"; };
      disk6 = { type = "disk"; device = "/dev/disk/by-id/wwn-0x5000c5008f0364e3"; };
      disk7 = { type = "disk"; device = "/dev/disk/by-id/wwn-0x5000c5008f0517e3"; };
    };
    zpool = {
      r730pool = {
        type = "zpool";
        mode = {
          # Define 4 mirrored VDEVs (pairs)
          val = "mirror disk0 disk1 mirror disk2 disk3 mirror disk4 disk5 mirror disk6 disk7";
        };
        rootFsOptions = {
          compression = "lz4";
          mountpoint = "none";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}
