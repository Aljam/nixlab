{ config, pkgs, domains, ... }: # <-- Added 'domains' here

{
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

    rules = [
      ''
        groups:
          - name: hardware_alerts
            rules:
              # Alert 1: If a server drops off the network for 5 minutes
              - alert: InstanceDown
                expr: up == 0
                for: 5m
                labels:
                  severity: critical
                annotations:
                  summary: "Host {{ $labels.instance }} is unreachable."

              # Alert 2: If CPU load stays above 85% for 10 minutes
              - alert: HighCpuLoad
                expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
                for: 10m
                labels:
                  severity: warning
                annotations:
                  summary: "CPU load on {{ $labels.instance }} has been > 85% for 10 minutes."

              # Alert 3: If your massive ZFS pool hits 85% capacity
              - alert: ZfsPoolCapacityWarning
                expr: zfs_pool_capacity > 85
                for: 5m
                labels:
                  severity: warning
                annotations:
                  summary: "ZFS Pool {{ $labels.pool }} on {{ $labels.instance }} is dangerously full."
      ''
    ];
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      port = 9100;
      enabledCollectors = [ "systemd" "zfs" ]; # Expose ZFS metrics for the alerts
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        root_url = "https://grafana.${domains.primary}"; 
        domain = "grafana.${domains.primary}";
        serve_from_sub_path = true;
      };
      security = {
        # Note: Since you use sops-nix, you might eventually want to move this secret key to secrets.yaml!
        secret_key = "$__file{${pkgs.writeText "grafana-secret-key" "SW2YcwTIb9zpOOhoPsMm"}}";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090"; # Points to your local Prometheus database
          isDefault = true;
        }
      ];
    };
  };

  # Added 9100 so the scraper isn't blocked by the firewall
  networking.firewall.allowedTCPPorts = [ 9090 3000 9100 ];
}
