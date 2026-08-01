{ config, pkgs, lib, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;

  # Standard Server Utilities
  environment.systemPackages = with pkgs; [
    smartmontools
    tmux
    htop
    lm_sensors
    pciutils
  ];

  # Global Drive Health Monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # Optional: Default ZFS scrubbing (can be disabled on the R820 since it uses hardware RAID)
  services.zfs.autoScrub.enable = lib.mkDefault true;
  services.zfs.autoScrub.interval = lib.mkDefault "weekly";
}
