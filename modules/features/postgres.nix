# nixlab/modules/features/postgres.nix
# PostgreSQL database with backup configuration

{ config, lib, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    settings.port = 5432;
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
      {
        name = "webscraper";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [
      "grafana"
      "webscraper"
    ];
  };

  services.pgadmin = {
    enable = true;
    port = 5050;
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets.pgadmin_password.path;
    settings = {
      DEFAULT_SERVER = "0.0.0.0";
    };
  };

  sops.secrets.pgadmin_password = {};

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

  # Firewall: allow pgadmin and postgres
  networking.firewall.allowedTCPPorts = [ 5050 5432 ];
}
