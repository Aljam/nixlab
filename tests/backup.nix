{ lib, nodes, ... }:

let
  # Test that PostgreSQL backups are created and encrypted
  testBackupCreation = { name, nodes, ... }: {
    name = "backup-creation";
    nodes = {
      server = { config, pkgs, ... }: {
        # Minimal PostgreSQL configuration with backups
        services.postgresql = {
          enable = true;
          ensureDatabases = [ "testdb" ];
          ensureUsers = [{
            name = "testuser";
            ensureDBOwnership = true;
          }];
          
          # Enable backup
          backup = {
            schedule = "0 2 * * *";
            compression = "zstd";
            backupDir = "/var/backup/postgresql";
          };
        };
      };
    };
    
    testScript = ''
      server.wait_for_unit("multi-user.target")
      
      # Backup directory exists
      server.succeed("test -d /var/backup/postgresql")
      
      # Backup permissions are correct
      server.succeed("stat -c '%U:%G' /var/backup/postgresql | grep -q 'postgres:postgres'")
      
      # Trigger manual backup
      server.succeed("systemctl start postgresql-backup.service")
      
      # Wait for backup to complete
      server.wait_for_unit("postgresql-backup.service")
      
      # Backup file exists and is encrypted
      server.succeed("test -f /var/backup/postgresql/latest.sql.zst.enc")
      
      # Backup is owned by postgres
      server.succeed("stat -c '%U' /var/backup/postgresql/latest.sql.zst.enc | grep -q 'postgres'")
      
      # Backup is not empty
      server.succeed("test -s /var/backup/postgresql/latest.sql.zst.enc")
    '';
  };
in
{
  imports = [
    testBackupCreation
  ];
}
