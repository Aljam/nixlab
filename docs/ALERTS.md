# Alerts & Monitoring

This document describes the alerting and monitoring configuration for nixlab infrastructure.

## Monitoring Stack

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Node Exporter  │     │   Prometheus     │     │    Grafana      │
│  (metrics)      │────▶│   (collection)   │────▶│   (visualization)│
└─────────────────┘     └────────┬─────────┘     └─────────────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │  Alertmanager    │
                        │   (alerting)     │
                        └────────┬─────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
             ┌──────────┐ ┌──────────┐ ┌──────────┐
             │  Email   │ │  Slack   │ │  Pager   │
             └──────────┘ └──────────┘ └──────────┘
```

## Components

### Node Exporter

**Purpose**: Collect system metrics (CPU, memory, disk, network)

```nix
# modules/roles/monitoring/default.nix
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = ["systemd" "filesystem" "netdev" "cpu" "meminfo"];
  };
}
```

**Metrics Collected**:
- CPU usage per core
- Memory usage (RAM, swap)
- Disk I/O and filesystem usage
- Network traffic per interface
- System load averages

### Prometheus

**Purpose**: Time-series database and query engine

```nix
# modules/roles/monitoring/default.nix
{
  services.prometheus = {
    enable = true;
    port = 9090;
    
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{ targets = ["localhost:9090"]; }];
      }
      {
        job_name = "node";
        static_configs = [{ targets = ["localhost:9100"]; }];
      }
      {
        job_name = "postgresql";
        static_configs = [{ targets = ["r820:9187"]; }];
      }
    ];
    
    retentionTime = "30d";
  };
}
```

### Grafana

**Purpose**: Visualization and dashboards

```nix
# modules/roles/monitoring/default.nix
{
  services.grafana = {
    enable = true;
    port = 3000;
    
    provision = {
      datasources = [{
        name = "Prometheus";
        type = "prometheus";
        url = "http://localhost:9090";
        isDefault = true;
      }];
      
      dashboards = [{
        name = "Node Exporter";
        url = "https://grafana.com/grafana/dashboards/1860.json";
        datasource = "Prometheus";
      }];
    };
  };
}
```

## Alert Rules

### System Alerts

```nix
# modules/roles/monitoring/default.nix
{
  services.prometheus.alertRules = ''
    # High CPU usage
    - alert: HighCPUUsage
      expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
    
    # High memory usage
    - alert: HighMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ $labels.instance }}"
    
    # Disk space low
    - alert: DiskSpaceLow
      expr: (node_filesystem_avail_bytes{fstype!~"tmpfs"} / node_filesystem_size_bytes{fstype!~"tmpfs"}) * 100 < 15
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Disk space low on {{ $labels.instance }}"
    
    # Disk space critical
    - alert: DiskSpaceCritical
      expr: (node_filesystem_avail_bytes{fstype!~"tmpfs"} / node_filesystem_size_bytes{fstype!~"tmpfs"}) * 100 < 5
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Disk space critical on {{ $labels.instance }}"
    
    # Service down
    - alert: ServiceDown
      expr: up == 0
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Service {{ $labels.job }} down on {{ $labels.instance }}"
  '';
}
```

### Backup Alerts

```nix
# modules/features/backup/default.nix
{
  services.prometheus.alertRules = ''
    # Backup failed
    - alert: BackupFailed
      expr: restic_backup_last_run_success == 0
      for: 1h
      labels:
        severity: critical
      annotations:
        summary: "Backup failed on {{ $labels.instance }}"
    
    # Backup too old
    - alert: BackupTooOld
      expr: time() - restic_backup_last_run_timestamp > 86400
      for: 1h
      labels:
        severity: warning
      annotations:
        summary: "Backup is too old on {{ $labels.instance }}"
  '';
}
```

## Notification Channels

### Email

```nix
# modules/features/alerting/default.nix
{
  services.prometheus.alertmanager.configuration = {
    receivers = [{
      name = "email";
      email_configs = [{
        to = "admin@example.com";
        from = "alertmanager@example.com";
        smarthost = "smtp.example.com:587";
        send_resolved = true;
      }];
    }];
  };
}
```

### Slack

```nix
# modules/features/alerting/default.nix
{
  services.prometheus.alertmanager.configuration = {
    receivers = [{
      name = "slack";
      slack_configs = [{
        api_url = "$__file{/run/secrets/slack-webhook-url}";
        channel = "#alerts";
        send_resolved = true;
      }];
    }];
  };
}
```

## Access

### Grafana Access

```
URL: https://grafana.example.com
Username: admin
Password: (from secrets)
```

### Prometheus Access

```
URL: https://prometheus.example.com
Authentication: Basic auth (from secrets)
```

## Troubleshooting

### Check Prometheus Targets

```bash
# List all scrape targets
curl http://localhost:9090/api/v1/targets | jq

# Check target health
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'
```

### Check Alerts

```bash
# List active alerts
curl http://localhost:9090/api/v1/alerts | jq

# List alert rules
curl http://localhost:9090/api/v1/rules | jq
```

### View Logs

```bash
# Prometheus logs
journalctl -u prometheus -f

# Grafana logs
journalctl -u grafana -f

# Alertmanager logs
journalctl -u alertmanager -f
```

## Best Practices

### 1. Use Meaningful Alert Names

```nix
# Good
- alert: PostgreSQLReplicationLag

# Bad
- alert: Lag
```

### 2. Set Appropriate Thresholds

```nix
# Warning threshold (actionable but not urgent)
for: 10m
labels:
  severity: warning

# Critical threshold (immediate action required)
for: 2m
labels:
  severity: critical
```

### 3. Include Context in Annotations

```nix
annotations:
  summary: "High CPU on {{ $labels.instance }}"
  description: "CPU usage is {{ $value }}% for more than 10 minutes"
  runbook_url: "https://wiki.example.com/runbooks/high-cpu"
```

### 4. Use Alert Routing

```nix
route:
  routes:
    - match:
        severity: critical
      receiver: pager
    - match:
        severity: warning
      receiver: email
```

---

**Last Updated**: August 2026