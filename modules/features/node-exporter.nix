{ lib, subnets, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
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
    firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
  };

  networking.firewall.allowedTCPPorts = [ 9100 ];
}
