{ config, pkgs, ... }: {
  services.zfs.autoScrub = {
    enable = true;
    interval = "Sun, 02:00";
  };
  services.sanoid = {
    enable = true;
    interval = "1h";
  };
}
