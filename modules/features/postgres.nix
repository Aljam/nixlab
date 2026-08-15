{ config, pkgs, lib, subnets, ... }:

let
  # Backup configuration
  backupDir = "/var/backup/postgresql";
  backupRetentionDays = 7;
in
{
  # SOPS secrets for PostgreSQL
  sops.secrets = {
    "pgadmin_password".owner = "pgadmin";
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_16;
    settings.password_encryption = "scram-sha-256";
    
    # Authentication configuration
    authentication = lib.mkOverride 10 ''
      local all all peer
      host all all 127.0.0.1/32 scram-sha-256
      host all all ${subnets.lan}.0/24 scram-sha-256
    '';
    
    # Database and user management
    ensureDatabases = [ "webscraper" "admin" ];
    ensureUsers = [
      {
        name = "admin";
        ensureDBOwnership = true;
      }
    ];
    
    # Automated backups with SOPS encryption
    backup = {
      # Daily backups at 2 AM
      schedule = "0 2 * * *";
      # Compress with zstd
      compression = "zstd";
      # Store in backup directory
      backupDir = backupDir;
      # Encrypt with SOPS (uses your existing .sops.yaml keys)
      postBackupHook = ''
        if [ -f ${backupDir}/latest.sql.zst ]; then
          ${pkgs.sops}/bin/sops --encrypt ${backupDir}/latest.sql.zst > ${backupDir}/latest.sql.zst.enc
          rm ${backupDir}/latest.sql.zst
        fi
      '';
    };
    
    # Performance tuning
    settings = {
      shared_buffers = "256MB";
      effective_cache_size = "1GB";
      work_mem = "16MB";
      maintenance_work_mem = "128MB";
      max_connections = 100;
      
      # Logging for audit
      log_destination = "stderr";
      logging_collector = true;
      log_directory = "log";
      log_filename = "postgresql-%Y-%m-%d_%H%M%S.log";
      log_rotation_age = "1d";
      log_rotation_size = "100MB";
      log_min_duration_statement = 1000;
      log_checkpoints = true;
      log_connections = true;
      log_disconnections = true;
      log_lock_waits = true;
    };
  };

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets.pgadmin_password.path;
    port = 5050;
    settings = {
      DEFAULT_SERVER = "${subnets.lan}.4";
      SESSION_COOKIE_SECURE = true;
      SESSION_COOKIE_SAMESITE = "Lax";
      LOGIN_ATTEMPTS = 5;
      LOCKOUT_TIME = 900;
    };
  };

  systemd.services.pgadmin.environment = {
    PGADMIN_LISTEN_ADDRESS = "${subnets.lan}.4";
  };

  # Ensure backup directory exists
  systemd.tmpfiles.rules = [
    "d ${backupDir} 0700 postgres postgres -"
    "d /var/log/postgresql 0755 postgres postgres -"
  ];

  # Backup rotation - delete encrypted backups older than 7 days
  systemd.services.postgresql-backup-rotate = {
    description = "Rotate old PostgreSQL backups";
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = "${pkgs.findutils}/bin/find ${backupDir} -name '*.sql.zst.enc' -mtime +${toString backupRetentionDays} -delete";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.postgresql-backup-rotate = {
    description = "Weekly backup rotation";
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  # Monitor backup success
  systemd.services.postgresql-backup-monitor = {
    description = "Check if PostgreSQL backup ran successfully";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -f ${backupDir}/latest.sql.zst.enc ] || [ $(find ${backupDir}/latest.sql.zst.enc -mtime +1) ]; then echo \"WARNING: PostgreSQL backup is stale\" >&2; exit 1; fi'";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.postgresql-backup-monitor = {
    description = "Daily backup monitoring";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  # Firewall rules
  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 ];
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 5050 accept
    ip saddr ${subnets.lan}.0/24 tcp dport 5432 accept
    ip saddr 127.0.0.1 tcp dport 5432 accept
    ip saddr 127.0.0.1 tcp dport 5050 accept
  '';
}
