# modules/features/postgres.nix
# Security: PostgreSQL and pgAdmin should NOT be exposed to LAN
# Only accessible via localhost or management subnet
{ config, lib, pkgs, ... }:

let
  # Use the fleet's reverse proxy IP from flake.nix instead of hardcoding
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
  managementSubnet = config.networking.subnets.management or [ "127.0.0.0/8" ];
in
{
  # PostgreSQL: Bind to localhost only
  services.postgresql = {
    enable = true;
    # Security: Listen only on localhost by default
    settings = {
      listen_addresses = "localhost";
      port = 5432;
    };
    
    # Restore webscraper and grafana databases and users
    ensureDatabases = [ "webscraper" "grafana" ];
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

  # pgAdmin: Bind to localhost only (not 0.0.0.0)
  services.pgadmin = {
    enable = true;
    # Security: Bind to localhost only
    bindAddress = "127.0.0.1";
    port = 5050;
    # Use sops for initial password
    initialEmail = "admin@localhost";
    initialPasswordFile = config.sops.secrets."pgadmin-password".path;
  };

  # Firewall rules managed centrally in reverse-proxy-backends.nix
  # No duplicate rules here - DRY principle
}
