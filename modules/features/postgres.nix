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
  
  # Create a wrapper script
  environment.etc."pgadmin4-run.py".text = ''
    import os
    import sys
    import glob
    
    # Set SERVER_ADDRESS before importing pgadmin4
    os.environ['SERVER_ADDRESS'] = '${bindAddr}'
    
    # Find pgadmin4 site-packages
    for path in glob.glob('/nix/store/*pgadmin*/lib/python*/site-packages'):
        if path not in sys.path:
            sys.path.insert(0, path)
    
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
      ExecStart = "${pkgs.python3}/bin/python3 /etc/pgadmin4-run.py";
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
