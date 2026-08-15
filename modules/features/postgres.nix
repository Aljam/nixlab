# nixlab/modules/features/postgres.nix
# PostgreSQL database with backup configuration

{ config, lib, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    port = 5432;
    dataDir = "/var/lib/postgresql";
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "grafana" ];
  };

  services.pgadmin = {
    enable = true;
    port = 5050;
  };

  # Custom backup service
  systemd.services.postgresql-backup = {
    description = "PostgreSQL backup service";
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
    script = ''
      mkdir -p /var/backup/postgresql
      pg_dumpall | zstd > /var/backup/postgresql/backup-$(date +%Y%m%d-%H%M%S).sql.zst
      
      # Keep only last 7 backups
      cd /var/backup/postgresql
      ls -t *.sql.zst | tail -n +8 | xargs -r rm
      
      # Update latest symlink
      ln -sf $(ls -t *.sql.zst | head -1) latest.sql.zst
    '';
  };

  systemd.timers.postgresql-backup = {
    description = "Daily PostgreSQL backup timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  # Firewall: PostgreSQL accessible only from HAProxy
  networking.firewall.allowedTCPPorts = [ 5432 ];
}
