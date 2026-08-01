{ config, pkgs, lib, ... }:

{
  imports = [
    ../features/sanoid.nix
  ];

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

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
      "processes"
      "cpu"
      "diskstats"
      "filesystem"
      "netdev"
      "zfs"
      "hwmon"
      "nvme"
    ];
  };

  # Open firewall if you want to scrape metrics from remote nodes into this central server
  # 3000 = Grafana, 13378 = Audiobookshelf, 7474 = Autobrr
  networking.firewall.allowedTCPPorts = [ 9100 3000 7474 13378];

  # Optional: Default ZFS scrubbing (can be disabled on the R820 since it uses hardware RAID)
  services.zfs.autoScrub.enable = lib.mkDefault true;
  services.zfs.autoScrub.interval = lib.mkDefault "weekly";
}
