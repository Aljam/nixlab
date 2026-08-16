# modules/features/postgres.nix
# Security: PostgreSQL and pgAdmin should NOT be exposed to LAN
# Only accessible via HAProxy gateway (192.168.1.1)
{ config, lib, pkgs, ... }:

let
  # Use host IP if set, otherwise localhost for security
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  sops.secrets."pgadmin_password" = {};
  
  # PostgreSQL: Bind to host IP for HAProxy access (or localhost if no host IP)
  services.postgresql = {
    enable = true;
    # Security: Listen on host IP (or localhost) only
    settings = {
      listen_addresses = lib.mkForce bindAddr;
      port = 5432;
    };
    
    # Restore webscraper and grafana databases and users
    ensureDatabases = [ "webscraper" "grafana" "aljam" ];
    ensureUsers = [
      {
        name = "webscraper";
        ensureDBOwnership = true;
      }
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
      {
        name = "aljam";
        ensureDBOwnership = true;
      }
    ];
  };

  # pgAdmin: Bind to host IP for HAProxy access (or localhost if no host IP)
  services.pgadmin = {
    enable = true;
    port = 5050;
    # Use sops for initial password
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets."pgadmin_password".path;
  };

  # Firewall rules managed centrally in reverse-proxy-backends.nix
  # No duplicate rules here - DRY principle
}
