{ config, pkgs, lib, subnets, ... }: {
  
  sops.secrets.pgadmin_password = {
    owner = "pgadmin";
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    settings.password_encryption = "scram-sha-256";
    authentication = lib.mkOverride 10 ''
    local all all peer
    host all all 127.0.0.1/32 scram-sha-256
    host all all ${subnets.lan}.0/24 scram-sha-256
    '';
    ensureDatabases = [ "webscraper" "admin" ];
    ensureUsers = [
      {
        name = "admin";
        ensureDBOwnership = true;
      }
    ];
  };

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@derezzed.info"; # Using your existing domain
    initialPasswordFile = config.sops.secrets.pgadmin_password.path;
    port = 5050; # Default port for the web interface
    settings = {
      DEFAULT_SERVER = "${subnets.lan}.4";
    };
  };

  systemd.services.pgadmin.environment = {
    PGADMIN_LISTEN_ADDRESS = "${subnets.lan}.4";
  };
}
