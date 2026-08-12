{ lib, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    listenAddress = "192.168.1.2";
    port = 9100;
    enabledCollectors = lib.mkForce [
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

  networking.firewall.allowedTCPPorts = [ 9100 ];
}
