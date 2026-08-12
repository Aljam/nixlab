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
    extraFlags = [ "--web.listen-address=0.0.0.0:9100" ];
  };

  networking.firewall.allowedTCPPorts = [ 9100 ];
}
