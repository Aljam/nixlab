{ lib, subnets, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
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
  
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.2 tcp dport 9100 accept
  '';
}
