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

  # Disable the NixOS pgadmin module
  services.pgadmin.enable = false;
  
  # Create wrapper script
  environment.etc."pgadmin4-wrapper.py".text = ''
    #!/usr/bin/env python3
    import os
    import sys
    
    # Set SERVER_ADDRESS before importing
    os.environ['SERVER_ADDRESS'] = '${bindAddr}'
    
    # Find and add pgadmin4 to path
    import glob
    for path in glob.glob('/nix/store/*pgadmin*/lib/python*/site-packages'):
        if path not in sys.path:
            sys.path.insert(0, path)
    
    # Import pgadmin4's app and run it
    from pgadmin4 import create_app
    app = create_app()
    app.run(host='${bindAddr}', port=5050)
  '';
  
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
      ExecStart = "${pkgs.python3}/bin/python3 /etc/pgadmin4-wrapper.py";
      Restart = "always";
    };
    
    preStart = ''
      mkdir -p /var/lib/pgadmin
      chown postgres:postgres /var/lib/pgadmin
    '';
  };

  # Allow direct access
  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 5050 ];
}
