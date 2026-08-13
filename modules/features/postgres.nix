{ config, pkgs, lib, ... }: {
  
  # 1. Define the secret for the pgAdmin initial setup
  # Make sure the pgadmin user owns the secret so it can read it during startup
  sops.secrets.pgadmin_password = {
    owner = "pgadmin";
  };

  # 2. Configure PostgreSQL
  services.postgresql = {
    enable = true;
    enableTCPIP = true; # Allows connections from other homelab nodes (e.g., your desktops/AI nodes)
    
    # Configure access rules (pg_hba.conf)
    authentication = pkgs.lib.mkOverride 10 ''
      # type database  DBuser  auth-method
      local all       all     trust
      host  all       all     127.0.0.1/32   trust
      host  all       all     ::1/128        trust
      # Allow your entire Tailscale or local subnet to authenticate with a password
      host  all       all     192.168.1.0/24 md5
    '';

    # Optional: Automatically create a default database and user on first boot
    ensureDatabases = [ "webscraper" "admin" ];
    ensureUsers = [
      {
        name = "admin";
        ensureDBOwnership = true;
      }
    ];
  };

  # 3. Configure pgAdmin Web UI
  services.pgadmin = {
    enable = true;
    initialEmail = "admin@derezzed.info"; # Using your existing domain
    openFirewall = true;
    initialPasswordFile = config.sops.secrets.pgadmin_password.path;
    port = 5050; # Default port for the web interface
    settings = {
      DEFAULT_SERVER = "0.0.0.0";
    };
  };

  systemd.services.pgadmin.environment = {
    PGADMIN_LISTEN_ADDRESS = "0.0.0.0";
  };

  # 4. Open the Firewall
  # 5432 = PostgreSQL | 5050 = pgAdmin Web UI
  networking.firewall.allowedTCPPorts = [ 5432 5050 ];
}
