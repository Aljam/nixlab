# nixlab/modules/features/postgres.nix
# PostgreSQL database with backup configuration

{ config, lib, pkgs, ... }:

{
  options.modules.features.postgres = {
    enable = lib.mkEnableOption "PostgreSQL database";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "PostgreSQL port";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/postgresql";
      description = "PostgreSQL data directory";
    };
    backupDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/backup/postgresql";
      description = "PostgreSQL backup directory";
    };
  };

  config = lib.mkIf config.modules.features.postgres.enable {
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
  };
}
