# nixlab/modules/features/postgres.nix
# PostgreSQL database with backup configuration

{ config, lib, pkgs, ... }:

{
    services.postgresql = {
      enable = true;
      port = config.modules.features.postgres.port;
      dataDir = config.modules.features.postgres.dataDir;
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
      port = config.modules.features.postgres.pgadminPort;
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
        mkdir -p ${config.modules.features.postgres.backupDir}
        pg_dumpall | zstd > ${config.modules.features.postgres.backupDir}/backup-$(date +%Y%m%d-%H%M%S).sql.zst
        
        # Keep only last 7 backups
        cd ${config.modules.features.postgres.backupDir}
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
    networking.firewall.allowedTCPPorts = [ config.modules.features.postgres.port ];
}
