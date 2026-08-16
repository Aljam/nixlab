# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
  };

  # Generate config.xml declaratively with correct port
  environment.etc."readarr/config.xml".text = ''
    <Config>
      <BindAddress>${bindAddr}</BindAddress>
      <Port>8787</Port>
      <SslPort>6868</SslPort>
      <EnableSsl>False</EnableSsl>
      <LaunchBrowser>True</LaunchBrowser>
      <ApiKey>71a5fa0bb47d49c88c263cc4954f3b88</ApiKey>
      <AuthenticationMethod>Forms</AuthenticationMethod>
      <AuthenticationRequired>Enabled</AuthenticationRequired>
      <Branch>develop</Branch>
      <LogLevel>debug</LogLevel>
      <SslCertPath></SslCertPath>
      <SslCertPassword></SslCertPassword>
      <UrlBase></UrlBase>
      <InstanceName>Readarr</InstanceName>
    </Config>
  '';

  # Copy config on activation
  systemd.services.readarr = {
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/cp -f /etc/readarr/config.xml /var/lib/readarr/config.xml"
      ];
    };
  };

  # Oneshot to fix corrupt database (run manually if needed)
  systemd.services.readarr-fix-db = {
    description = "Fix Readarr corrupt database";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      DB_DIR="/var/lib/readarr"
      if [ -f "$DB_DIR/readarr.db" ]; then
        # Check if db is corrupt by trying to open it
        if ! ${pkgs.sqlite}/bin/sqlite3 "$DB_DIR/readarr.db" "SELECT 1;" 2>/dev/null; then
          echo "Database corrupt, backing up..."
          mv "$DB_DIR/readarr.db" "$DB_DIR/readarr.db.corrupt"
          mv "$DB_DIR/readarr.db-shm" "$DB_DIR/readarr.db-shm.corrupt" 2>/dev/null || true
          mv "$DB_DIR/readarr.db-wal" "$DB_DIR/readarr.db-wal.corrupt" 2>/dev/null || true
          # Restore from backup if exists
          if [ -f "$DB_DIR/Backups/readarr_backup_*.db" ]; then
            cp "$DB_DIR/Backups/readarr_backup_"*.db "$DB_DIR/readarr.db"
            echo "Restored from backup"
          else
            echo "No backup, will create fresh db on next start"
          fi
          chown readarr:readarr "$DB_DIR"/*.db* 2>/dev/null || true
        fi
      fi
    '';
  };
}
