{ config, pkgs, ... }:

{
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub = {
    enable = true;
    interval = "Sun, 02:00";
  };
}
