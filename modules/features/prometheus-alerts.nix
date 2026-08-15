{ config, pkgs, lib, ... }:

{
  # Prometheus alerting rules for critical infrastructure monitoring
  
  services.prometheus = {
    enable = true;
    
    alertmanagers = [
      {
        staticConfigs = ["localhost:9093"];
      }
    ];
    
    ruleFiles = [
      # This will be generated below
    ];
  };
  
  # Alerting rules configuration
  services.prometheus.rules = {
    # System Resource Alerts
    "system" = {
      groups = [
        {
          name = "system-alerts";
          rules = [
            # High CPU usage
            {
              alert = "HighCPUUsage";
              expr = "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 80";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "High CPU usage detected on {{ $labels.instance }}";
                description = "CPU usage is above 80% for more than 5 minutes. Current value: {{ $value }}%";
              };
            }
            {
              alert = "CriticalCPUUsage";
              expr = "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 95";
              for = "2m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Critical CPU usage on {{ $labels.instance }}";
                description = "CPU usage is above 95% for more than 2 minutes. Current value: {{ $value }}%";
              };
            }
            
            # High Memory usage
            {
              alert = "HighMemoryUsage";
              expr = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "High memory usage on {{ $labels.instance }}";
                description = "Memory usage is above 80% for more than 5 minutes. Current value: {{ $value }}%";
              };
            }
            {
              alert = "CriticalMemoryUsage";
              expr = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 95";
              for = "2m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Critical memory usage on {{ $labels.instance }}";
                description = "Memory usage is above 95% for more than 2 minutes. Current value: {{ $value }}%";
              };
            }
            
            # Disk space
            {
              alert = "LowDiskSpace";
              expr = "(node_filesystem_avail_bytes{fstype!=\"tmpfs\"} / node_filesystem_size_bytes{fstype!=\"tmpfs\"}) * 100 < 20";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Low disk space on {{ $labels.instance }} ({{ $labels.mountpoint }})";
                description = "Disk space is below 20% on {{ $labels.mountpoint }}. Current value: {{ $value }}%";
              };
            }
            {
              alert = "CriticalDiskSpace";
              expr = "(node_filesystem_avail_bytes{fstype!=\"tmpfs\"} / node_filesystem_size_bytes{fstype!=\"tmpfs\"}) * 100 < 10";
              for = "2m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Critical disk space on {{ $labels.instance }} ({{ $labels.mountpoint }})";
                description = "Disk space is below 10% on {{ $labels.mountpoint }}. Current value: {{ $value }}%";
              };
            }
          ];
        }
      ];
    };
    
    # Service Health Alerts
    "services" = {
      groups = [
        {
          name = "service-alerts";
          rules = [
            # Service down
            {
              alert = "ServiceDown";
              expr = "up == 0";
              for = "1m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Service {{ $labels.job }} is down on {{ $labels.instance }}";
                description = "The service {{ $labels.job }} has been down for more than 1 minute.";
              };
            }
            
            # PostgreSQL specific
            {
              alert = "PostgreSQLDown";
              expr = "pg_up == 0";
              for = "1m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "PostgreSQL is down on {{ $labels.instance }}";
                description = "PostgreSQL database has been down for more than 1 minute.";
              };
            }
            {
              alert = "PostgreSQLConnectionsHigh";
              expr = "pg_stat_activity_count{state=\"active\"} > 100";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "High PostgreSQL connections on {{ $labels.instance }}";
                description = "PostgreSQL has {{ $value }} active connections.";
              };
            }
            
            # Jellyfin specific
            {
              alert = "JellyfinDown";
              expr = "probe_success{job=\"jellyfin\"} == 0";
              for = "2m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Jellyfin is down on {{ $labels.instance }}";
                description = "Jellyfin media server has been unreachable for more than 2 minutes.";
              };
            }
            
            # SSH specific
            {
              alert = "SSHDown";
              expr = "probe_success{job=\"ssh\"} == 0";
              for = "2m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "SSH is down on {{ $labels.instance }}";
                description = "SSH service has been unreachable for more than 2 minutes.";
              };
            }
            
            # Grafana specific
            {
              alert = "GrafanaDown";
              expr = "probe_success{job=\"grafana\"} == 0";
              for = "2m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Grafana is down on {{ $labels.instance }}";
                description = "Grafana monitoring dashboard has been unreachable for more than 2 minutes.";
              };
            }
          ];
        }
      ];
    };
    
    # SSL/TLS Certificate Alerts
    "ssl" = {
      groups = [
        {
          name = "ssl-alerts";
          rules = [
            {
              alert = "SSLCertExpiringSoon";
              expr = "probe_ssl_earliest_cert_expiry - time() < 86400 * 30";
              for = "1h";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "SSL certificate expiring soon on {{ $labels.instance }}";
                description = "SSL certificate will expire in less than 30 days. Expiry: {{ $value | humanizeDuration }}";
              };
            }
            {
              alert = "SSLCertExpiringVerySoon";
              expr = "probe_ssl_earliest_cert_expiry - time() < 86400 * 7";
              for = "1h";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "SSL certificate expiring very soon on {{ $labels.instance }}";
                description = "SSL certificate will expire in less than 7 days. Expiry: {{ $value | humanizeDuration }}";
              };
            }
          ];
        }
      ];
    };
  };
  
  # Alertmanager configuration
  services.alertmanager = {
    enable = true;
    
    configuration = {
      global = {
        smtp_smarthost = "localhost:25";
        smtp_from = "alertmanager@example.com";
      };
      
      route = {
        group_by = ["alertname", "severity"];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
        receiver = "default-receiver";
        
        routes = [
          {
            match = { severity = "critical"; };
            receiver = "critical-receiver";
          }
          {
            match = { severity = "warning"; };
            receiver = "warning-receiver";
          }
        ];
      };
      
      receivers = [
        {
          name = "default-receiver";
          email_configs = [
            {
              to = "aljam@live.ca";
              send_resolved = true;
            }
          ];
        }
        {
          name = "critical-receiver";
          email_configs = [
            {
              to = "aljam@live.ca";
              send_resolved = true;
              html = ''
                <html>
                  <body>
                    <h2>🚨 Critical Alert</h2>
                    <p><strong>Alert:</strong> {{ .GroupLabels.alertname }}</p>
                    <p><strong>Instance:</strong> {{ .GroupLabels.instance }}</p>
                    <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
                    <p><strong>Time:</strong> {{ .StartsAt }}</p>
                  </body>
                </html>
              '';
            }
          ];
        }
        {
          name = "warning-receiver";
          email_configs = [
            {
              to = "aljam@live.ca";
              send_resolved = true;
            }
          ];
        }
      ];
    };
  };
}
