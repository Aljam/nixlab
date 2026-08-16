{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName;
  bindAddr = config.networking.fleet.${hostname}.ip;
  pgadminPkg = pkgs.pgadmin4;
  python3 = pkgs.python3;
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
  
  # Create a wrapper script that sets SERVER_ADDRESS
  environment.etc."pgadmin4-run.py".text = ''
    import os
    import sys
    
    # Set SERVER_ADDRESS before importing pgadmin4
    os.environ['SERVER_ADDRESS'] = '${bindAddr}'
    
    # Add pgadmin4 to path
    sys.path.insert(0, '${pgadminPkg}/lib/python3.11/site-packages')
    
    # Import and run
    from pgadmin4 import pgAdmin4
    pgAdmin4.run()
  '';
  
  # Create custom pgadmin service
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
      ExecStart = "${python3}/bin/python3 /etc/pgadmin4-run.py";
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
