{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName;
  bindAddr = config.networking.fleet.${hostname}.ip;
in
{
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
      # Add explicit /32 rules for approved remote application clients.
      # Do not restore a broad LAN-wide rule here.
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
    settings = {
      DEFAULT_SERVER = bindAddr;
    };
  };
}
