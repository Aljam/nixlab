# Monitoring Alerts

This document describes the monitoring alerts configured in nixlab.

## Alert Overview

nixlab includes comprehensive Prometheus alerting rules for monitoring:
- System resources (CPU, memory, disk)
- Service health (PostgreSQL, Jellyfin, SSH, Grafana)
- SSL/TLS certificates

## Alert Categories

### 1. System Resource Alerts

#### CPU Usage

| Alert | Threshold | Duration | Severity |
|-------|-----------|----------|----------|
| HighCPUUsage | > 80% | 5 minutes | Warning |
| CriticalCPUUsage | > 95% | 2 minutes | Critical |

**Runbook**:
1. Check running processes: `top` or `htop`
2. Identify resource-intensive processes
3. Consider scaling or optimizing workloads
4. Check for runaway processes or infinite loops

#### Memory Usage

| Alert | Threshold | Duration | Severity |
|-------|-----------|----------|----------|
| HighMemoryUsage | > 80% | 5 minutes | Warning |
| CriticalMemoryUsage | > 95% | 2 minutes | Critical |

**Runbook**:
1. Check memory usage: `free -h`
2. Identify memory-hungry processes: `ps aux --sort=-%mem | head`
3. Check for memory leaks
4. Consider adding swap or upgrading RAM
5. Restart memory-leaking services if needed

#### Disk Space

| Alert | Threshold | Duration | Severity |
|-------|-----------|----------|----------|
| LowDiskSpace | < 20% free | 5 minutes | Warning |
| CriticalDiskSpace | < 10% free | 2 minutes | Critical |

**Runbook**:
1. Check disk usage: `df -h`
2. Find large files: `du -ah | sort -rh | head -20`
3. Clean up old logs: `journalctl --vacuum-time=7d`
4. Remove old Nix generations: `nix-collect-garbage --delete-older-than 7d`
5. Clear package cache: `nix-store --gc`
6. Consider expanding storage

### 2. Service Health Alerts

#### Service Down

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| ServiceDown | up == 0 | 1 minute | Critical |

**Runbook**:
1. Check service status: `systemctl status <service>`
2. Check service logs: `journalctl -u <service> -b`
3. Attempt to restart: `systemctl restart <service>`
4. Check for dependency failures
5. Review recent changes or updates

#### PostgreSQL

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| PostgreSQLDown | pg_up == 0 | 1 minute | Critical |
| PostgreSQLConnectionsHigh | > 100 active | 5 minutes | Warning |

**Runbook**:
1. Check PostgreSQL status: `systemctl status postgresql`
2. Check connections: `psql -c "SELECT count(*) FROM pg_stat_activity;"`
3. Check for long-running queries
4. Review connection pool settings
5. Check disk space for database

#### Jellyfin

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| JellyfinDown | probe fails | 2 minutes | Critical |

**Runbook**:
1. Check Jellyfin status: `systemctl status jellyfin`
2. Check logs: `journalctl -u jellyfin -b`
3. Verify port 8096 is listening: `ss -tlnp | grep 8096`
4. Check media storage is accessible
5. Restart if needed: `systemctl restart jellyfin`

#### SSH

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| SSHDown | probe fails | 2 minutes | Critical |

**Runbook**:
1. Check SSH status: `systemctl status sshd`
2. Check logs: `journalctl -u sshd -b`
3. Verify port 22 is listening: `ss -tlnp | grep 22`
4. Check firewall rules: `nft list ruleset`
5. Check for failed login attempts: `journalctl -u sshd | grep "Failed"`

#### Grafana

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| GrafanaDown | probe fails | 2 minutes | Critical |

**Runbook**:
1. Check Grafana status: `systemctl status grafana`
2. Check logs: `journalctl -u grafana -b`
3. Verify port 3000 is listening: `ss -tlnp | grep 3000`
4. Check database connectivity
5. Restart if needed: `systemctl restart grafana`

### 3. SSL/TLS Certificate Alerts

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|----------|
| SSLCertExpiringSoon | < 30 days | 1 hour | Warning |
| SSLCertExpiringVerySoon | < 7 days | 1 hour | Critical |

**Runbook**:
1. Check certificate expiry: `echo | openssl s_client -connect <host>:443 2>/dev/null | openssl x509 -noout -dates`
2. Renew certificate using your certificate provider
3. For Let's Encrypt: `certbot renew`
4. Reload services using the certificate
5. Verify new certificate is active

## Alert Severity Levels

### Critical
- Immediate action required
- Service is down or about to fail
- Paged immediately
- Response time: < 15 minutes

### Warning
- Action needed soon
- Resource thresholds exceeded
- Notified via email
- Response time: < 4 hours

## Alert Configuration

Alerts are configured in:
- `modules/features/prometheus-alerts.nix` - Alert rules
- `modules/features/grafana.nix` - Grafana dashboards
- `modules/features/prometheus-server.nix` - Prometheus server

## Notification Channels

Alerts are sent to:
- Email: `admin@example.com` (configure in alertmanager)
- Can be extended to:
  - Slack
  - PagerDuty
  - Pushover
  - Webhook

## Testing Alerts

To test alerts:

```bash
# Manually trigger a test alert
curl -X POST http://localhost:9093/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "alerts": [
      {
        "labels": {
          "alertname": "TestAlert",
          "severity": "warning"
        },
        "annotations": {
          "summary": "Test alert",
          "description": "This is a test"
        }
      }
    ]
  }'
```

## Grafana Dashboards

Pre-configured dashboards:
- System Overview - CPU, memory, disk
- Service Health - All monitored services
- SSL Certificates - Certificate expiry tracking

Access at: `http://<host>:3000`

## Adding New Alerts

To add a new alert:

1. Edit `modules/features/prometheus-alerts.nix`
2. Add rule to appropriate group:

```nix
{
  alert = "MyNewAlert";
  expr = "my_metric > threshold";
  for = "5m";
  labels = {
    severity = "warning";
  };
  annotations = {
    summary = "Description of the alert";
    description = "Detailed description with {{ $value }} and {{ $labels.instance }}";
  };
}
```

3. Add runbook to this document
4. Test the alert
5. Deploy and verify

## Maintenance

### Weekly
- Review triggered alerts
- Check for alert fatigue
- Update thresholds if needed

### Monthly
- Review and update runbooks
- Test alert notification channels
- Clean up obsolete alerts

### Quarterly
- Full alert system review
- Add alerts for new services
- Remove unused alerts

## Resources

- [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- [Grafana Alerts](https://grafana.com/docs/grafana/latest/alerting/)

---

**Last Updated**: August 2026
