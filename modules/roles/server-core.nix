{ config, pkgs, lib, ... }:

{
  imports = [
    ../features/sanoid.nix
    ../features/monitoring.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;

  environment.systemPackages = with pkgs; [
    smartmontools
    tmux
    htop
    lm_sensors
    pciutils
  ];

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

  # 3000: Grafana | 7474: Autobrr | 9100: Node Exporter | 13378: Audiobookshelf
  networking.firewall.allowedTCPPorts = [ 9100 3000 7474 13378 ];

  services.zfs.autoScrub.enable = lib.mkDefault true;
  services.zfs.autoScrub.interval = lib.mkDefault "weekly";
}
