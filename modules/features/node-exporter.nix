{ lib, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    listenAddress = "0.0.0.0";
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
