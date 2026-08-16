{ config, pkgs, lib, ... }: {
  
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
    host all all ${options.networking.subnets.lan}.0/24 scram-sha-256
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

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@derezzed.info"; # Using your existing domain
    initialPasswordFile = config.sops.secrets.pgadmin_password.path;
    port = 5050; # Default port for the web interface
    settings = {
      DEFAULT_SERVER = "${config.options.servicesHostIP}";
    };
  };

  systemd.services.pgadmin.environment = {
    PGADMIN_LISTEN_ADDRESS = "${config.options.servicesHostIP}";
  };

  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 ];
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.proxy.ip} tcp dport 5050 accept
  '';
}
