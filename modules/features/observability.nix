{ config, pkgs, ... }:

{
  # --- 1. Node Exporter (Runs on every machine to expose hardware metrics) ---
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
      "zfs"
      "hwmon"      # Essential for monitoring CPU/motherboard temperatures
      "nvme"       # Essential for NVMe health tracking
    ];
  };

  # --- 2. Prometheus (Scrapes metrics locally or across the fleet) ---
  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      {
        job_name = "nixos-local";
        static_configs = [
          { targets = [ "127.0.0.1:9100" ]; }
        ];
      };
      # If you want to scrape other servers in your fleet, add their IPs here:
      # {
      #   job_name = "r730-compute";
      #   static_configs = [ { targets = [ "192.168.1.X:9100" ]; } ];
      # }
    ];
  };

  # --- 3. Grafana (The Visualization UI) ---
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        # Change this if you map a domain via HAProxy later (e.g. https://grafana.derezzed.info)
        domain = "localhost"; 
      };
    };
  };

  # Open firewall if you want to scrape metrics from remote nodes into this central server
  networking.firewall.allowedTCPPorts = [ 9100 ];
}
