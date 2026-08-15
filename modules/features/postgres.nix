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
    "postgres-backup-encryption-key".owner = "postgres";  # Optional: for encrypted backups
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_16;  # Explicit version
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
        # Additional security: restrict superuser privileges
        # superuser = false;  # Uncomment if admin doesn't need superuser
      }
    ];
    
    # Automated backups
    backup = {
      # Daily backups at 2 AM
      schedule = "0 2 * * *";
      # Compress with zstd (faster and better compression than gzip)
      compression = "zstd";
      # Store in backup directory
      backupDir = backupDir;
      # Optional: Encrypt backups (requires SOPS key)
      # encryptionCommand = "gpg --encrypt --recipient backup@yourdomain.com";
    };
    
    # Performance tuning (optional - adjust based on your hardware)
    settings = {
      # Memory settings (adjust based on available RAM)
      shared_buffers = "256MB";
      effective_cache_size = "1GB";
      work_mem = "16MB";
      maintenance_work_mem = "128MB";
      
      # Connection settings
      max_connections = 100;
      
      # Logging for audit
      log_destination = "stderr";
      logging_collector = true;
      log_directory = "log";
      log_filename = "postgresql-%Y-%m-%d_%H%M%S.log";
      log_rotation_age = "1d";
      log_rotation_size = "100MB";
      log_min_duration_statement = 1000;  # Log queries > 1 second
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
      # Security hardening
      SESSION_COOKIE_SECURE = true;  # Only send cookies over HTTPS
      SESSION_COOKIE_SAMESITE = "Lax";
      # Rate limiting
      LOGIN_ATTEMPTS = 5;  # Max login attempts before lockout
      LOCKOUT_TIME = 900;  # Lockout duration (15 minutes)
    };
  };

  systemd.services.pgadmin.environment = {
    PGADMIN_LISTEN_ADDRESS = "${subnets.lan}.4";
  };

  # Ensure backup directory exists with proper permissions
  systemd.tmpfiles.rules = [
    "d ${backupDir} 0700 postgres postgres -"
    "d /var/log/postgresql 0755 postgres postgres -"
  ];

  # Backup rotation - delete backups older than 7 days
  systemd.services.postgresql-backup-rotate = {
    description = "Rotate old PostgreSQL backups";
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = "${pkgs.findutils}/bin/find ${backupDir} -name '*.sql.zst' -mtime +${toString backupRetentionDays} -delete";
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

  # Monitor backup success (optional)
  systemd.services.postgresql-backup-monitor = {
    description = "Check if PostgreSQL backup ran successfully";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -f ${backupDir}/latest.sql.zst ] || [ $(find ${backupDir}/latest.sql.zst -mtime +1) ]; then echo \"WARNING: PostgreSQL backup is stale\" >&2; exit 1; fi'";
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

  # Firewall: Only allow HAProxy (pfSense) and LAN subnet
  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 ];
  networking.firewall.extraInputRules = ''
    # Allow HAProxy (pfSense gateway) to reach pgAdmin
    ip saddr ${subnets.lan}.1 tcp dport 5050 accept
    
    # Allow LAN subnet for database connections
    ip saddr ${subnets.lan}.0/24 tcp dport 5432 accept
    
    # Allow localhost
    ip saddr 127.0.0.1 tcp dport 5432 accept
    ip saddr 127.0.0.1 tcp dport 5050 accept
  '';
}
