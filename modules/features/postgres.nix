{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName;
  bindAddr = config.networking.fleet.${hostname}.ip;
  pgadminPkg = pkgs.pgadmin4;
in
{
  sops.secrets.pgadmin_password = {
    owner = "postgres";
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    settings.password_encryption = "scram-sha-256";
    authentication = lib.mkOverride 10 ''
      local all all peer
      host all all 127.0.0.1/32 scram-sha-256
      host all all ${config.networking.subnets.lan}.0/24 scram-sha-256
    '';
    ensureDatabases = [ "webscraper" "admin" ];
    ensureUsers = [
      {
        name = "webscraper";
        ensureDBOwnership = true;
      }
      {
        name = "admin";
        ensureDBOwnership = true;
      }
    ];
  };

  # Disable the NixOS pgadmin module service
  services.pgadmin.enable = false;
  
  # Create custom pgadmin service that binds to network IP
  systemd.services.pgadmin = {
    description = "pgAdmin4";
    after = [ "network.target" "postgresql.service" ];
    wants = [ "network.target" "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "postgres";
      Group = "postgres";
      WorkingDirectory = "/var/lib/pgadmin";
      Environment = "SERVER_ADDRESS=${bindAddr}";
      ExecStart = "${pgadminPkg}/bin/pgadmin4";
      Restart = "always";
    };
    
    preStart = ''
      mkdir -p /var/lib/pgadmin
      chown postgres:postgres /var/lib/pgadmin
    '';
  };

  # Allow direct access to pgadmin on the network interface
  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 5050 ];
  networking.firewall.extraInputRules = ''
    ip saddr ${config.networking.fleet.proxy.ip} tcp dport 5050 accept
  '';
}
