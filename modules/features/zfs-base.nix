{ config, pkgs, ... }

{
  services.zfs.autoScrub = {
    enable = true;
    interval = "Sun, 02:00";
  };
}
