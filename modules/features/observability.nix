{ config, pkgs, domains, ... }:

{
  sops.secrets.alertmanager-password = {};
  sops.defaultSopsFile = ../../../secrets/secrets.yaml

  # Enable and Configure Alertmanager for Email
  services.prometheus.alertmanager = {
    enable = true;
    port = 9093;
    
    # Securely loads the secret and substitutes $SMTP_PASSWORD below
    environmentFile = config.sops.secrets."alertmanager.env".path;
    
    configuration = {
      global = {
        # Replace with your SMTP provider (e.g., smtp.gmail.com:587)
        smtp_smarthost = "smtp.mail-provider.com:587"; 
        smtp_from = "alerts@${domains.primary}";
        smtp_auth_username = "your-email@example.com";
        smtp_auth_password = "$SMTP_PASSWORD"; 
        smtp_require_tls = true;
      };
      
      route = {
        group_by = [ "alertname" "instance" ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
        receiver = "email";
      };
      
      receivers = [
        {
          name = "email";
          email_configs = [
            {
              # The email address that will receive the alerts
              to = "your-personal-email@example.com";
              send_resolved = true;
              headers = {
                Subject = "[{{ .Status | toUpper }}] {{ .GroupLabels.alertname }} (NixOS Fleet)";
              };
            }
          ];
        }
      ];
    };
  };

  services.prometheus = {
    enable = true;
    port = 9090;

    alertmanagers = [
      {
        scheme = "http";
        static_configs = [ { targets = [ "127.0.0.1:9093" ]; } ];
      }
    ];
    
    scrapeConfigs = [
      {
        job_name = "nixos-local";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
      }
    ];

    rules = [
      ''
        groups:
          - name: hardware_alerts
            rules:
              - alert: InstanceDown
                expr: up == 0
                for: 5m
                labels:
                  severity: critical
                annotations:
                  summary: "Host {{ $labels.instance }} is unreachable."

              - alert: HighCpuLoad
                expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
                for: 10m
                labels:
                  severity: warning
                annotations:
                  summary: "CPU load on {{ $labels.instance }} has been > 85% for 10 minutes."

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
      enabledCollectors = [ "systemd" "zfs" ]; 
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
          url = "http://127.0.0.1:9090"; 
          isDefault = true;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 9090 3000 9100 9093 ];
}
