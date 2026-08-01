{ config, pkgs, ... }:

{
  # Declare the SOPS secret
  sops.secrets."grafana.env" = {
    sopsFile = ../../secrets/grafana.enc.env; # Adjust path to match your layout
    format = "dotenv";
    owner = "grafana";
    group = "grafana";
  };

  # --- Node Exporter (Runs on every machine to expose hardware metrics) ---
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
      "hwmon"      # Essential for monitoring CPU/motherboard temperatures
      "nvme"       # Essential for NVMe health tracking
    ];
  };

  # --- Prometheus (Scrapes metrics locally or across the fleet) ---
  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      {
        job_name = "nixos-local";
        static_configs = [
          { targets = [ "127.0.0.1:9100" ]; }
        ];
      }
      # If you want to scrape other servers in your fleet, add their IPs here:
      # {
      #   job_name = "r730-compute";
      #   static_configs = [ { targets = [ "192.168.1.X:9100" ]; } ];
      # }
    ];
  };

  # --- Grafana (The Visualization UI) ---
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "https://grafana.derezzed.info"; 
      };
      security = {
        secretKeyFile = config.sops.secrets."grafana.env".path;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 9090 3000 9100 ];
}
