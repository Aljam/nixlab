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

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@derezzed.info";
    initialPasswordFile = config.sops.secrets.pgadmin_password.path;
    port = 5050;
  };

  # pgadmin4 doesn't support SERVER_ADDRESS via NixOS module
  # Just use haproxy to proxy to localhost:5050

  networking.firewall.interfaces.eno1.allowedTCPPorts = [ 5432 ];
  networking.firewall.extraInputRules = ''
    ip saddr ${config.networking.fleet.proxy.ip} tcp dport 5050 accept
  '';
}
