{ lib, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = lib.mkForce [ "systemd" "zfs" ];
  };
  networking.firewall.allowedTCPPorts = [ 9100 ];
}
