{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName;
  bindAddr = config.networking.fleet.${hostname}.ip;
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

  # Disable NixOS pgadmin module
  services.pgadmin.enable = false;
  
  # Create a shell wrapper that sets env and runs pgadmin4
  environment.etc."pgadmin4-run.sh".text = ''
    #!/bin/sh
    export SERVER_ADDRESS=${bindAddr}
    export PGADMIN_PORT=5050
    exec ${pkgs.pgadmin4}/bin/pgadmin4
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
      ExecStart = "/etc/pgadmin4-run.sh";
      Restart = "always";
      Environment = [
        "SERVER_ADDRESS=${bindAddr}"
        "PGADMIN_PORT=5050"
      ];
    };
    
    preStart = ''
      mkdir -p /var/lib/pgadmin
      chown postgres:postgres /var/lib/pgadmin
    '';
  };

  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 5050 ];
}
