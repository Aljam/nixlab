{ config, pkgs, lib, ... }:

{
  imports = [
    ../features/observability.nix
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

  # --- Node Exporter (Runs on every machine to expose hardware metrics) ---
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
      "hwmon"      # Essential for monitoring CPU/motherboard temperatures
      "nvme"       # Essential for NVMe health tracking
    ];
  };

  # Open firewall if you want to scrape metrics from remote nodes into this central server
  networking.firewall.allowedTCPPorts = [ 9100 ];

  # Optional: Default ZFS scrubbing (can be disabled on the R820 since it uses hardware RAID)
  services.zfs.autoScrub.enable = lib.mkDefault true;
  services.zfs.autoScrub.interval = lib.mkDefault "weekly";
}
