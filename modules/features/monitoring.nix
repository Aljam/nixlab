{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop
    
    # Workaround for upstream pytest failures
    (glances.overrideAttrs (oldAttrs: {
      doCheck = false;
      dontCheck = true;
      pytestCheckPhase = "true";
    }))

    iotop
    sysstat
  ];

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
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
}
