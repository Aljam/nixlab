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
    # For production, consider connection settings for specific applications
    settings = {
      listen_addresses = "localhost";
      port = 5432;
    };
  };

  # pgAdmin: Bind to localhost only (not 0.0.0.0)
  services.pgadmin = {
    enable = true;
    # Security: Bind to localhost only
    bindAddress = "127.0.0.1";
    port = 5050;
    # Use sops for initial password
    initialEmail = config.users.users.${config.networking.hostName}.email or "admin@localhost";
    initialPasswordFile = config.sops.secrets."pgadmin-password".path;
  };

  # Firewall: Restrict PostgreSQL and pgAdmin to localhost only
  # DO NOT open ports 5432 and 5050 to the LAN
  # If management access is needed, use a specific management subnet
  networking.firewall = {
    # Only allow from localhost (implicit) and optionally management subnet
    extraInputRules = ''
      # PostgreSQL: localhost only (or management subnet if needed)
      ${lib.concatMapStringsSep "\n" (subnet: 
        "ip saddr ${subnet} tcp dport 5432 accept"
      ) managementSubnet}
      
      # pgAdmin: localhost only (or management subnet if needed)
      ${lib.concatMapStringsSep "\n" (subnet: 
        "ip saddr ${subnet} tcp dport 5050 accept"
      ) managementSubnet}
    '';
  };
}
