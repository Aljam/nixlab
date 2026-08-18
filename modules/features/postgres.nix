{ config, pkgs, lib, ... }:

let
  bindAddr = config.servicesHostIP;
in
{
  networking.proxyBackendPorts = [ 5050 ];

  sops.secrets.pgadmin_password = {
    owner = "pgadmin";
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;

    settings = {
      listen_addresses = lib.concatStringsSep "," [
        "127.0.0.1"
        bindAddr
      ];
      password_encryption = "scram-sha-256";
    };

    authentication = lib.mkOverride 10 ''
      local all all peer
      host all all 127.0.0.1/32 scram-sha-256
      host all all ${bindAddr}/32 scram-sha-256
      # Add narrower /32 rules for approved remote application clients.
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
    settings.DEFAULT_SERVER = bindAddr;
  };
}
