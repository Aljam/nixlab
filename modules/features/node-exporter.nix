{ lib, subnets, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    listenAddress = "0.0.0.0";
    port = 9100;
    enabledCollectors = lib.mkForce [
      "systemd"
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
  networking.firewall.extraInput = "ip saddr 192.168.1.2 tcp dport 9100 accept";
}
